#!/usr/bin/perl
use warnings;
use Storable;
use strict;
use feature 'unicode_strings';
use Digest::MD5 qw(md5);

die "perl $0 <one or more N-CSR/N-CSRS/N-Q>\n" if @ARGV == 0;

# Constants
my $monthConversion = ' JANUARY 1 FEBRUARY 2 MARCH 3 APRIL 4 MAY 5 JUNE 6 JULY 7 AUGUST 8 SEPTEMBER 9 OCTOBER 10 NOVEMBER 11 DECEMBER 12 ';
my @possibleCurrencyAry = ('$','USD','EUR','GBP','JPY','CNY','CAD','AUD','SGD','CHF','HKD','KRW','NOK','NZD','RUB','SEK');
my @protectedWords = ('NOTIONAL','CURRENCY','COUNTER','CLEARING','BUY','SELL','RATING','REFERENCE','ISSUER','DELIVERABLE','INDEX','TRANCH');
my @headerWords = ('NOTIONAL','CURRENCY','COUNTER','CLEARING','RATING','REFERENCE','ISSUER','DELIVERABLE','TRANCH','CONTRACT','APPRECIATION','SETTLEMENT','AMOUNT','RECEIVE','DELIVER','DATE','DEFAULT','SWAP','PREMIUM','FRONT','PREMIUM','REALIZE','PURCHASED','MARGIN','UP-FRONT','PERIODIC','TERMINATION','REMAINING');
my $maxHeaderCol = 6;
# Global variables per file
my $fulltext = "";
my $currentFN = "";
my $totalTables = 0;

sub DBG {
  print STDERR join "\t", @_;
  print STDERR "\n";
}

sub DBGR {
  my $idx = 0;
  print STDERR "|";
  foreach my $x (@_) {
    if(defined $x) { print STDERR "$idx:$x|"; }
    else {print STDERR "$idx:|"; }
    ++$idx;
  }
  print STDERR "\n";
}

sub Max ($$) { $_[$_[0] < $_[1]] }
sub Min ($$) { $_[$_[0] > $_[1]] }

sub Uniq {
  my %seen;
  return grep { !$seen{$_}++ } @_;
}

sub Argmax {
  return -1 if @_ == 0;
  my $index = 0;
  my $max = defined $_[0] ? $_[0] : 0;
  for(my $i = 1; $i < @_; ++$i) {
    if(defined $_[$i] && $_[$i] >= $max) { $index = $i; }
  }
  return $index;
}

sub Trim {
  my $s = shift @_;
  $s = "" if not defined $s;
  $s =~ s/^\s+//g;
  $s =~ s/\s+$//g;
  return $s
}

sub HitACurrency {
  my $s = shift @_;
  $s =~ s/\s+//g;
  my $match = 0;
  foreach my $i (@possibleCurrencyAry) {
    if("$s" eq "$i") {
      ++$match;
    }
  }
  #&DBG("HitACurrency: ", $s, $match);
  if($match > 0) {return 1}
  else {return 0}
}

sub HasACurrency {
  my $s = shift @_;
  my $match = 0;
  foreach my $i (@possibleCurrencyAry) {
    if($s =~ /\Q$i/) {
      ++$match;
    }
  }
  #&DBG("HasACurrency: ", $s, $match);
  if($match > 0) {return 1}
  else {return 0}
}

sub ThreeSpace2Newline {
  my $s = shift;
  $s =~ s/   /\n/g;
  return $s;
}

sub GetContentWithTag {
  my $tag = shift @_;
  my @return = ();
  while($fulltext =~ /<$tag.*?>(.*?)<\/$tag>/g) { push @return, $1; }
  return @return;
}

sub RemoveTableInterval {
  my $str = shift @_;
  $str =~ s/<\/TABLE>.*?<TABLE>//g;
  return $str;
}

sub RemoveDualTableInterval {
  my $str = shift @_;
  #&DBG("Before", $str);
  $str =~ s/<\/TABLE>.*?<TABLE>.*?<\/TABLE>.*?<TABLE>//g;
  #&DBG("After", $str);
  return $str;
}

sub RemoveTableIntervalWithTagWithoutWords {
  my $str = shift @_;
  my $tag = shift @_;
  my @words = @_;
  my $noGo = 0;
  if($str =~ /\Q$tag/) {
    foreach my $i (@words) {
      ++$noGo if $str =~ /\Q$i/;
    }
    if ($noGo == 0) {
      $str =~ s/<\/TABLE>.*?<TABLE>//g;
    }
  }
  return $str;
}

sub GetPreceedingWithKeyword {
  my $keyword = shift @_;
  my $length = shift @_;
  my @return = ();
  while($fulltext =~ /(.{$length})$keyword/g) { push @return, $1; }
  return @return;
}

sub GetSubsequentWithKeywordNonOverlap {
  my $keyword = shift @_;
  my $length = shift @_;
  my @return = ();
  while($fulltext =~ /$keyword(.{$length})/g) { push @return, $1; }
  return @return;
}

sub GetFlankingWithKeywordNonOverlap {
  my $s = shift @_;
  my $keyword = shift @_;
  my $length = shift @_;
  $length = int($length/2+0.5);
  my @return = ();
  $s =~ s/(.{$length}$keyword.{$length})/push @return, $1; ''/ge;
  return @return;
}

sub GetFlankingWithKeyword {
  my $s = shift @_;
  my $keyword = shift @_;
  my $length = shift @_;
  $length = int($length/2+0.5);
  my @return = ();
  while($s =~ /($keyword)/g) {
    my $left = substr($s, &Max(0,$-[0]-$length), &Min($length, $-[0]));
    my $right = substr($s, $+[0], $length);
    push @return, "$left$1$right";
  }
  return @return;
}

sub GetSubsequentWithKeyword {
  my $s = shift @_;
  my $keyword = shift @_;
  my $length = shift @_;
  my @return = ();
  my $backward = 1500;
  while($s =~ /($keyword)/g) {
    my $rightPos = $+[0];
    my $leftPos = $-[0];
    my $pos = $+[0];
    my $keyword = $1;
    my $left = substr($s, &Max(0, $leftPos-$backward), &Min($leftPos, $backward));
    my $right = "";
    while(1) {
      $right = substr($s, $rightPos, $length);
      if($right =~ /<\/TABLE>/) {last;}
      $length *= 1.5;
      if($length >= length($fulltext)) {last;}
    }
    push @return, "$left$keyword$right";
  }
  return @return;
}

sub PrintArray {
  my $a = shift @_;
  my $i = 0;
  foreach(@$a) { print STDERR "$i\t$_\n"; ++$i; }
}

sub Head2Bar {
  my $a = shift @_;
  my @return = ();
  foreach(@$a) {
    if(/^(.*?)\|/) { push @return, &Trim($1);}
    else { push @return, $_; }
  }
  return @return;
}

sub Bar2Tail {
  my $a = shift @_;
  my @return = ();
  foreach(@$a) {
    if(/\|(.*?)$/) { push @return, &Trim($1); }
    else { push @return, $_; }
  }
  return @return;
}

sub ShowCDSTable {
  my $tbl = shift @_;
  for(my $j = 0; $j < scalar(@{$tbl}); ++$j) {
    my @t = @{$$tbl[$j]};
    #print STDERR "Raw: $t[0]\n";
    #print STDERR "Left: $t[1]\n";
    #print STDERR "Right: $t[2]\n";
    for(my $x = 4; $x < scalar(@t); ++$x) { # first row starting from 4
      for(my $y = 0; $y < scalar(@{$t[$x]}); ++$y) {
        #print STDERR "$t[$x][$y]\t" if defined $t[$x][$y];
      }
      #print STDERR "\n";
    }
  }
}

my $rowGe = 6;  # 4 variables (match string, left string, right string, flags) + 2 table rows
my $columnGe = 2;
sub GetRealTables {
  my $l = shift @_;
  my @return = ();
  my $i = 0;
  while($l=~/<TABLE.*?>(.*?)<\/TABLE>/g) {
    ++$totalTables;
    my $tableDbgSwitch = 0;
    my $tr=$1;
    my @tbl = ();
    $tbl[0] = $1; # matched string
    $tbl[1] = substr($l, &Max(0,$-[0]-200), &Min(200, $-[0]));
    $tbl[2] = substr($l, $+[0], 200);
    $tbl[3] = 0; # flags, 0x1: buy/sell determined, 0x2: buy or sell, 0x4: buy/sell appended, 0x8 redundant table, 0x10 rating
    my $j = 4;  # first row starting from 4
    my $buySwitch = 0; my $sellSwitch = 0;
    {
      my $countBuy = 0;
      my $countSell = 0;
      while($tbl[1] =~ /BUY/g) {$countBuy+=1}
      while($tbl[1] =~ /PURCHASE/g) {$countBuy+=1}
      while($tbl[1] =~ /SELL/g) {$countSell+=1}
      while($tbl[1] =~ /SOLD/g) {$countSell+=1}
      while($tbl[1] =~ /SALE/g) {$countSell+=1}
      while($tbl[1] =~ /WRITTEN/g) {$countSell+=1}
      my $reduce = &Min($countBuy, $countSell);
      $countBuy -= $reduce; $countSell -= $reduce;
      #&DBG("Buy/Sell: ", $countBuy, $countSell);
      if($countBuy > $countSell && $countSell == 0)
      {
        #$tbl[3] |= 0x1;
        #&DBG($countBuy, $countSell, $tbl[3], $tbl[0]);
        #&DBG("BUY", $countBuy, $countSell);
        $buySwitch = 1;
      }
      if($countBuy < $countSell && $countBuy == 0)
      {
        #$tbl[3] |= 0x1; $tbl[3] |= 0x2;
        #&DBG($countBuy, $countSell, $tbl[3], $tbl[0]);
        #&DBG("SELL", $countBuy, $countSell);
        $sellSwitch = 1;
      }
    }
    while($tr=~/<TR.*?>(.*?)<\/TR>/g) {
      my $td=$1;
      @{$tbl[$j]} = ();
      my $k = 0;
      my $realMaterialCount = 0;
      my $skipTheRow = 0;
      while($td=~/<TD.*?>(.*?)<\/TD>/g) {
        if($k == 0 && $j != 4 && $1 =~ /TOTAL/) { $skipTheRow = 1; last; }
        $tbl[$j][$k] = &Trim($1);
        ++$realMaterialCount if $tbl[$j][$k] ne "";
        #if ($tbl[$j][$k] eq "CBK") { $tableDbgSwitch = 1 };
        if((($k < 5 && $j != 4) || ($k == 1 && $j == 4)) && $tbl[$j][$k] =~ /BUY/) { $buySwitch = 1; $sellSwitch = 0; $skipTheRow = 1; }
        if((($k < 5 && $j != 4) || ($k == 1 && $j == 4)) && $tbl[$j][$k] =~ /PURCHASE/) { $buySwitch = 1; $sellSwitch = 0; $skipTheRow = 1; }
        if((($k < 5 && $j != 4) || ($k == 1 && $j == 4)) && $tbl[$j][$k] =~ /SELL/) { $sellSwitch = 1; $buySwitch = 0; $skipTheRow = 1; }
        if((($k < 5 && $j != 4) || ($k == 1 && $j == 4)) && $tbl[$j][$k] =~ /SOLD/) { $sellSwitch = 1; $buySwitch = 0; $skipTheRow = 1; }
        if((($k < 5 && $j != 4) || ($k == 1 && $j == 4)) && $tbl[$j][$k] =~ /SALE/) { $sellSwitch = 1; $buySwitch = 0; $skipTheRow = 1; }
        if((($k < 5 && $j != 4) || ($k == 1 && $j == 4)) && $tbl[$j][$k] =~ /WRITTEN/) { $sellSwitch = 1; $buySwitch = 0; $skipTheRow = 1; }
        if((($k < 5 && $j != 4) || ($k == 1 && $j == 4)) && $tbl[$j][$k] =~ /RATING/) { $tbl[3] |= 0x10; }
        ++$k;
      }
      if($realMaterialCount == 0) {
        $skipTheRow = 1;
        @{$tbl[$j]} = undef;
      }
      elsif($realMaterialCount > 0) {
        if($buySwitch == 1) {
          $tbl[3] |= 0x4;
          for(my $x = $j; $x >=4 ; --$x) {
            if(not defined $tbl[$x][$k]) {
              $tbl[$x][$k] = "BUY";
            } else {
              last;
            }
          }
          #&DBG("Added BUY");
        }
        if($sellSwitch == 1) {
          $tbl[3] |= 0x4;
          for(my $x = $j; $x >=4 ; --$x) {
            if(not defined $tbl[$x][$k]) {
              $tbl[$x][$k] = "SELL";
            } else {
              last;
            }
          }
          #&DBG("Added SELL");
        }
      }
      ++$j unless $skipTheRow == 1;
    }
    if( $j == 4 ) # first row starting from 4
    # Converting spaces back to newlines to tackle with the stupid filers who didn't use tags in the reports
    {
      my $raw = &ThreeSpace2Newline($tr);
      my @rows = split "\n", $raw;
      my $buySwitch = 0; my $sellSwitch = 0;
      foreach my $row (@rows) {
        next if $row =~ /^- -|^---|---$/;
        @{$tbl[$j]} = ();
        my $k = 0;
        my @columns = split / {2,}/, $row;
        my $realMaterialCount = 0;
        my $skipTheRow = 0;
        foreach my $col (@columns) {
          if($k == 0 && $j != 4 && $1 =~ /TOTAL/) { $skipTheRow = 1; last; }
          $tbl[$j][$k] = &Trim($col);
          ++$realMaterialCount if $tbl[$j][$k] ne "";
          if((($k < 5 && $j != 4) || ($k == 1 && $j == 4)) && $tbl[$j][$k] =~ /BUY/) { $buySwitch = 1; $sellSwitch = 0; $skipTheRow = 1; }
          if((($k < 5 && $j != 4) || ($k == 1 && $j == 4)) && $tbl[$j][$k] =~ /PURCHASE/) { $buySwitch = 1; $sellSwitch = 0; $skipTheRow = 1; }
          if((($k < 5 && $j != 4) || ($k == 1 && $j == 4)) && $tbl[$j][$k] =~ /SELL/) { $sellSwitch = 1; $buySwitch = 0; $skipTheRow = 1; }
          if((($k < 5 && $j != 4) || ($k == 1 && $j == 4)) && $tbl[$j][$k] =~ /SOLD/) { $sellSwitch = 1; $buySwitch = 0; $skipTheRow = 1; }
          if((($k < 5 && $j != 4) || ($k == 1 && $j == 4)) && $tbl[$j][$k] =~ /SALE/) { $sellSwitch = 1; $buySwitch = 0; $skipTheRow = 1; }
          if((($k < 5 && $j != 4) || ($k == 1 && $j == 4)) && $tbl[$j][$k] =~ /WRITTEN/) { $sellSwitch = 1; $buySwitch = 0; $skipTheRow = 1; }
          if((($k < 5 && $j != 4) || ($k == 1 && $j == 4)) && $tbl[$j][$k] =~ /RATING/) { $tbl[3] |= 0x10; }
          ++$k;
        }
        if($realMaterialCount == 0) {
          $skipTheRow = 1;
          @{$tbl[$j]} = undef;
        }
        elsif($realMaterialCount > 0) {
          if($buySwitch == 1) {
            $tbl[3] |= 0x4;
            for(my $x = $j; $x >=4 ; --$x) {
              if(not defined $tbl[$x][$k]) {
                $tbl[$x][$k] = "BUY";
              } else {
                last;
              }
            }
          }
          if($sellSwitch == 1) {
            $tbl[$j][$k] = "SELL";
            $tbl[3] |= 0x4;
            for(my $x = $j; $x >=4 ; --$x) {
              if(not defined $tbl[$x][$k]) {
                $tbl[$x][$k] = "SELL";
              } else {
                last;
              }
            }
          }
        }
        ++$j unless $skipTheRow == 1;
      }
    }
    my $maxCol = 0;
    # first row starting from 4
    for(my $x = 4; $x < scalar(@tbl); ++$x) { if(scalar(@{$tbl[$x]}) > $maxCol) {$maxCol = scalar(@{$tbl[$x]});} }
    if($tableDbgSwitch == 1) {
      &DBG("tableDbgSwitch", scalar(@tbl), $maxCol);
    }
    #&DBG("Row/Col: ", scalar(@tbl), $maxCol);
    #for(my $x = 4; $x < scalar(@tbl); ++$x) {
    #  &DBGR(@{$tbl[$x]});
    #}
    if(@tbl >= $rowGe && $maxCol >= $columnGe) {
      @{$return[$i]} = @tbl; ++$i;
    }
  }
  #&DBG(scalar(@return));
  return @return;
}

sub ProtectTheRowOrNot {
  my @row = @_;
  my $protect = 0;
  foreach my $x (@row) {
    foreach my $y (@protectedWords) {
      next if not defined $x;
      ++$protect if $x=~/\Q$y/;
    }
  }

  return $protect;
}

sub CopyArray {
  my $tbl = shift @_;
  my @t = @$tbl;
  my @rt;
  for(my $x = 0; $x < scalar(@t); ++$x) {
    for(my $y = 0; $y < @{$t[$x]}; ++$y) {
      if(defined $t[$x][$y]) {
        $rt[$x][$y] = $t[$x][$y];
      } else {
        $rt[$x][$y] = "";
      }
    }
  }
  return @rt;
}

sub ExpandMultiParagraphRow {
  my $tbl = shift @_;
  my @t = @$tbl;
  return () if scalar(@t) == 0;
  my @rt;
  my $idx = 0;
  for(my $x = 0; $x < scalar(@t); ++$x) {
    my $maxJump = 0;
    my $maxCol = 0;
    for(my $y = 0; $y < @{$t[$x]}; ++$y) {
      my @paragraphs = split "    ", $t[$x][$y];
      $maxJump = &Max($maxJump, scalar(@paragraphs));
      $maxCol = &Max($maxCol, scalar(@{$t[$x]}));
      for(my $z = 0; $z < @paragraphs; ++$z) {
        #&DBG("a paragraph: ", $paragraphs[$z]);
        $rt[$idx+$z][$y] = $paragraphs[$z];
      }
    }
    for(my $z = 0; $z < $maxJump; ++$z ) {
      for(my $y = 0; $y < $maxCol; ++$y) {
        $rt[$idx+$z][$y] = "" if not defined $rt[$idx+$z][$y];
      }
    }
    $idx += $maxJump;
  }
  return @rt;
}

sub RemoveAlmostEmptyRow {
  my $tbl = shift @_;
  my @t = @$tbl;
  return () if scalar(@t) == 0;
  my @rt;
  my $idx = 0;
  for(my $x = 0; $x < scalar(@t); ++$x) {
    my $notMissing = 0;
    for(my $y = 0; $y < @{$t[$x]}; ++$y) {
      $t[$x][$y] = "" if not defined $t[$x][$y];
      ++$notMissing if ($t[$x][$y] ne "" && $t[$x][$y] ne "SELL" && $t[$x][$y] ne "BUY" && $t[$x][$y] !~ /^\s+$/);
    }
    if($notMissing > 0) {
      for(my $y = 0; $y < @{$t[$x]}; ++$y) {
        $rt[$idx][$y] = $t[$x][$y];
      }
      ++$idx;
    }
  }
  return @rt;
}

sub MergeExpandedRow {
  my $tbl = shift @_;
  my @t = @$tbl;
  return () if scalar(@t) == 0;
  return @t if scalar(@t) == 1;
  my @rt=();
  my $idx = 0;
  for(my $x = 0; $x < (@t-1); ++$x) {
    my $firstRowWord = 0; my $secondRowWord = 0; my $rowCount = 0; my $permit = 1;
    for(my $y = 0; $y < scalar(@{$t[$x]}); ++$y) {
      ++$rowCount if $t[$x][$y] ne "";
    }
    for(my $y = 0; $y < scalar(@{$t[$x+1]}); ++$y) {
      $permit = 0 if $t[$x+1][$y] =~ /^\s*[\(\)\d,]+\s*$/;
    }
    for(my $y = 0; $y < scalar(@{$t[$x]}); ++$y) {
      foreach my $i (@headerWords) { if($t[$x][$y] =~ /$i/) {
          ++$firstRowWord;
          #&DBG("Header match1: ", $i, $t[$x][$y]);
        }
      }
    }
    for(my $y = 0; $y < scalar(@{$t[$x+1]}); ++$y) {
      foreach my $i (@headerWords) {
        if($t[$x+1][$y] =~ /$i/) {
          ++$secondRowWord;
          #&DBG("Header match2: ", $i, $t[$x+1][$y]);
        }
      }
    }
    #$t[$x][0] = "$rowCount/$permit/$firstRowWord/$secondRowWord $t[$x][0]";
    if($rowCount == 0) {
    } elsif ($firstRowWord >= 2 && $secondRowWord >= 1) {
        for(my $y = 0; $y < &Max(scalar(@{$t[$x]}),scalar(@{$t[$x+1]})); ++$y) {
          if(not defined $t[$x+1][$y]) { $t[$x+1][$y] = "" }
          if(not defined $t[$x][$y]) { $t[$x][$y] = "" }
          $t[$x+1][$y] = "$t[$x][$y] $t[$x+1][$y]";
        }
        #&DBG("MG1: ", $t[$x+1][0]);
    } elsif ($rowCount <= 2 && $permit == 0 && $secondRowWord < 1 && $firstRowWord < 1) {
        for(my $y = 0; $y < &Max(scalar(@{$t[$x]}),scalar(@{$t[$x+1]})); ++$y) {
          if(not defined $t[$x+1][$y]) { $t[$x+1][$y] = "" }
          if(not defined $t[$x][$y]) { $t[$x][$y] = "" }
          $t[$x+1][$y] = "$t[$x][$y] $t[$x+1][$y]";
        }
        #&DBG("MG2: ", $t[$x+1][0]);
    } elsif ($permit == 1 && $rowCount <= int(0.4*scalar(@{$t[$x]})) && $secondRowWord < 1 && $firstRowWord < 1) {
        for(my $y = 0; $y < &Max(scalar(@{$t[$x]}),scalar(@{$t[$x+1]})); ++$y) {
          if(not defined $t[$x+1][$y]) { $t[$x+1][$y] = "" }
          if(not defined $t[$x][$y]) { $t[$x][$y] = "" }
          $t[$x+1][$y] = "$t[$x][$y] $t[$x+1][$y]";
        }
        #&DBG("MG3: ", $t[$x+1][0]);
    } else {
      for(my $y = 0; $y < scalar(@{$t[$x]}); ++$y) {
        $rt[$idx][$y] = $t[$x][$y];
      }
      ++$idx;
    }
  }
  my $lastRow = scalar(@t)-1;
  for(my $y = 0; $y < scalar(@{$t[$lastRow]}); ++$y) {
    $rt[$idx][$y] = $t[$lastRow][$y];
  }


  return @rt;
}

sub RemoveEmptyColumn {
  my $tbl = shift @_;
  my @t = @$tbl;
  my @rt=();
  return @rt if scalar(@t) == 0;
  my @emptyCount = ();
  my $rows = scalar(@t) - 1;
  my $maxCol = 0;
  for(my $x = 0; $x < scalar(@t); ++$x) {
    $maxCol = scalar(@{$t[$x]}) if scalar(@{$t[$x]}) > $maxCol;
  }
  for(my $y = 0; $y < $maxCol; ++$y) { $emptyCount[$y] = 0; }
  for(my $x = 1; $x < scalar(@t); ++$x) {
    for(my $y = 0; $y < $maxCol; ++$y) {
      if(not defined $t[$x][$y]) { ++$emptyCount[$y]; }
      elsif($t[$x][$y] eq "" || $t[$x][$y] =~ /^\s+$/) { ++$emptyCount[$y]; }
    }
  }
  for(my $y = 0; $y < $maxCol; ++$y) {
    if($emptyCount[$y] == $rows) { $emptyCount[$y] = 0; }
    else { $emptyCount[$y] = 1; }
  }
  for(my $x = 0; $x < scalar(@t); ++$x) {
    @{$rt[$x]} = ();
    my $idx = 0;
    for(my $y = 0; $y < $maxCol; ++$y) {
      if($emptyCount[$y] == 1) { if(defined $t[$x][$y]){$rt[$x][$idx] = $t[$x][$y]}else{$rt[$x][$idx]=""}; ++$idx; }
    }
  }

  return @rt;
}

sub DownfillColumns {
  my $tbl = shift @_;
  my $refCol = shift @_;
  my $amountCol = shift @_;
  my @t = @$tbl;
  my @rt=();
  return @t if scalar(@t) <= 1;
  my $maxCol = 0;
  my @currencyFilldown = ();
  for(my $x = 0; $x < scalar(@t); ++$x) {
    $maxCol = scalar(@{$t[$x]}) if scalar(@{$t[$x]}) > $maxCol;
  }
  my @cache = ();
  for(my $y = 0; $y < $maxCol; ++$y) { $cache[$y] = ""; $currencyFilldown[$y] = 0; }
  @{$rt[0]} = ();
  for(my $y = 0; $y < $maxCol; ++$y) { $rt[0][$y] = $t[0][$y]; }
  for(my $x = 1; $x < scalar(@t)-1; ++$x) {
    @{$rt[$x]} = ();
    my $nextHeader = 0; my $currentHeader = 0; my $previousHeader = 0;
    for(my $y = 0; $y < $maxCol; ++$y) {
      $t[$x+1][$y] = "" if not defined $t[$x+1][$y];
      $t[$x][$y] = "" if not defined $t[$x][$y];
      $t[$x-1][$y] = "" if not defined $t[$x-1][$y];
      foreach my $i (@headerWords) { if($t[$x+1][$y] =~ /$i/) {++$nextHeader;}}
      foreach my $i (@headerWords) { if($t[$x][$y] =~ /$i/) {++$currentHeader;}}
      foreach my $i (@headerWords) { if($t[$x-1][$y] =~ /$i/) {++$previousHeader;}}
    }
    if ($nextHeader >= 2) { for(my $y = 0; $y < $maxCol; ++$y) { $cache[$y] = ""; } }
    if ($currentHeader >= 2) { for(my $y = 0; $y < $maxCol; ++$y) { $cache[$y] = ""; } }
    if ($previousHeader >= 2) { for(my $y = 0; $y < $maxCol; ++$y) { $cache[$y] = ""; } }
    if ($previousHeader >= 2 && $currentHeader <= 1 && $nextHeader <= 1) {
      for(my $y = 0; $y < $maxCol; ++$y) {
        if(&HitACurrency($t[$x][$y])) {
          $currencyFilldown[$y] = 1;
        } else {
          $currencyFilldown[$y] = 0;
        }
      }
    }
    for(my $y = 0; $y < $maxCol; ++$y) {
      if($t[$x][$y] ne "") {
        $rt[$x][$y] = $t[$x][$y];
        if($currencyFilldown[$y] == 0 && $previousHeader <= 1 && &HitACurrency($t[$x][$y])) {
          $cache[$y] = "";
        } else {
          $cache[$y] = $t[$x][$y];
        }
      } elsif ($y != $refCol && $y != $amountCol) {
        $rt[$x][$y] = $cache[$y];
      } else {
        $rt[$x][$y] = "";
      }
    }
  }
  {
    my $x = scalar(@t)-1;
    @{$rt[$x]} = ();
    for(my $y = 0; $y < $maxCol; ++$y) {
      if(defined $t[$x][$y]) {
        $rt[$x][$y] = $t[$x][$y];
      } else {
        $rt[$x][$y] = "";
      }
    }
  }

  return @rt;
}

sub Run {
  # Variables per file
  my $accessNum = ""; my $rptYr = ""; my $rptSeq = "";
  my $rptCik = ""; my $rptName = ""; my $rptFileAsOfDate = "";
  my $startDate = ""; my $endDate = "";
  my @cdsStrings = (); my @cdsTables = (); my $isCDS = 0; my $remainingText = "";
  my $globalInThousand = 0;

  # Get 'Accession number', 'reporting year' and 'reporting sequence'
  if(1)
  {
    $currentFN =~ /(\d+?)-(\d+?)-(\d+)/;
    $accessNum = $1; $rptYr = $2; $rptSeq = $3;
    #&DBG($accessNum, $rptYr, $rptSeq);
  }

  # Get 'CIK', 'fund name', 'file as of date' and global in thousand
  if(1)
  {
    my @r1 = &GetSubsequentWithKeywordNonOverlap('COMPANY CONFORMED NAME', 150);
    my @r2 = &GetSubsequentWithKeywordNonOverlap('FILED AS OF DATE', 150);
    my @r3 = &GetSubsequentWithKeywordNonOverlap('CENTRAL INDEX KEY', 150);
    my @r4 = &GetSubsequentWithKeywordNonOverlap('IN\s+THOUSANDS', 1);
    if(@r1 > 0)
    {
      my $s = $r1[0];
      if($s =~ /\s+(.*?)[ ]{2,}/) {
        $rptName = $1;
      } else { $rptName = "." }
    }
    if(@r2 > 0)
    {
      my $s = $r2[0];
      if($s =~ /(\d{4})(\d{2})(\d{2})/) {
        my $ey = $1; my $em = $2; my $ed = $3;
        $rptFileAsOfDate = "$em/$ed/$ey";
      }
    } else {$rptFileAsOfDate = "."}
    if(@r3 > 0) {
      my $s = $r1[0];
      if($s =~ /\s+(\d+)/) {
        $rptCik = $1;
      }
    } else { $rptCik = "." }
    if(@r4 > 0) {
      $globalInThousand = 1;
    }
    #&DBG($rptCik, $rptName, $rptFileAsOfDate, $globalInThousand);
  }

  # Get 'reporting period'
  if(1)
  {
    my @r1 = &GetSubsequentWithKeywordNonOverlap('DATE\s+OF\s+REPORTING\s+PERIOD', 150);
    my @r2 = &GetSubsequentWithKeywordNonOverlap('CONFORMED PERIOD OF REPORT', 150);
    #&PrintArray(\@r1);
    my $flag = 0;
    if(@r1 > 0)
    {
      my $s = $r1[0];
      if($s =~ /(\w+?)\s+?(\d+?),\s+?(\d+?)\s+?\S+?\s+(\w+?)\s+?(\d+?),\s+?(\d+)/) {
        my $sm = uc($1); my $sd = $2; my $sy = $3; my $em = uc($4); my $ed = $5; my $ey = $6;
        $monthConversion =~ / $sm.*?(\d+)/; $sm = $1;
        $monthConversion =~ / $em.*?(\d+)/; $em = $1;
        $startDate = "$sm/$sd/$sy"; $endDate = "$em/$ed/$ey";
        $flag = 1;
      }
      elsif($s =~ /(\w+?)\s+?(\d+?),\s+?(\d+)/) {
        my $em = uc($1); my $ed = $2; my $ey = $3;
        $monthConversion =~ / $em.*?(\d+)/; $em = $1;
        $startDate = "."; $endDate = "$em/$ed/$ey";
        $flag = 1;
      }
      elsif($s =~ /(\d+?)\/(\d+?)\/(\d+)/) {
        my $em = $1; my $ed = $2; my $ey = $3;
        if($em > 12) {my $t = $em; $em = $ed; $ed = $t;}
        if(length($ey) == 2) {$ey = "20".$ey;}
        $startDate = "."; $endDate = "$em/$ed/$ey";
        $flag = 1;
      }
      else{ $startDate = "."; $endDate = "."; }
    }
    if($flag == 0 && @r2 > 0)
    {
      my $s = $r2[0];
      if($s =~ /(\d{4})(\d{2})(\d{2})/) {
        my $ey = $1; my $em = $2; my $ed = $3;
        $startDate = "."; $endDate = "$em/$ed/$ey";
        $flag = 1;
      }
    }
    #&DBG($startDate, $endDate);
  }

  # Get CDS related strings
  if(1)
  {
    my $localFulltext = $fulltext;
    my @s1 = &GetSubsequentWithKeyword($localFulltext, 'CREDIT\s+?DEFAULT', 50000);
    #&PrintArray(\@s1);
    my @s2 = &GetSubsequentWithKeyword($localFulltext, 'CDS\s+?CONTRACTS', 30000);
    #&PrintArray(\@s2);
    my @s3 = &GetSubsequentWithKeyword($localFulltext, 'DEFAULT\s+?SWAP', 30000);
    #&PrintArray(\@s3);
    my @s4 = &GetSubsequentWithKeyword($localFulltext, 'DEFAULT\s+?CONTRACT', 30000);
    #&PrintArray(\@s4);
    my @s5 = &GetSubsequentWithKeyword($localFulltext, 'DEFAULT\s+?PROTECTION', 30000);
    #&PrintArray(\@s5);
    my @s6 = &GetSubsequentWithKeyword($localFulltext, 'CREDIT\s+?DERIVATIVE', 30000);
    #&PrintArray(\@s6);
    push @cdsStrings, @s1, @s2, @s3, @s4, @s5, @s6;
    $isCDS = 1 if @cdsStrings > 0;
    $remainingText = $localFulltext;
    #&PrintArray(\@cdsStrings);
  }

  # Get CDS related tables
  if(1 && $isCDS == 1)
  {
    print "--------------------------------------------FOUND CDS---------------------------------------------------------------------------------------------------\n";
    print "META\tACCESSION NUMBER\tREPORTING YEAR\tREPORTING SEQUENCE\tREPORTING CIK\tFUND NAME\tFILE AS OF DATE\tSTART DATE\tEND DATE\tKEYWORDS\n";
    print "META\t$accessNum\t$rptYr\t$rptSeq\t$rptCik\t$rptName\t$rptFileAsOfDate\t$startDate\t$endDate\tKEYWORDS\t".(scalar(@cdsStrings))."\n";
    for(my $i = 0; $i < scalar(@cdsStrings); ++$i) {
      push @cdsTables, &GetRealTables($cdsStrings[$i]);
      #&DBG("Num tables: ", scalar(@cdsTables), $totalTables);
      #for(my $x = 4; $x < scalar(@{$cdsTables[-1]}); ++$x) { &DBGR(@{$cdsTables[-1][$x]}); }
    }
    #&ShowCDSTable(\@cdsTables);
    print "--------------------------------------------END OF CDS---------------------------------------------------------------------------------------------------\n";
  }

  # Mark redundant tables
  if(1 && $isCDS == 1)
  {
    my %fingerprints = ();
    for(my $j = 0; $j < scalar(@cdsTables); ++$j) {
      my $F = md5($cdsTables[$j][0]);
      if(defined $fingerprints{$F}) { $cdsTables[$j][3] |= 0x8; }
      else { $fingerprints{$F} = 1; }
    }
  }

  # Extract information
  if(1 && $isCDS == 1)
  {
    my @finalOutputs = ();
    my $numSkip = 0; my $numItem = 0;
    for(my $j = 0; $j < scalar(@cdsTables); ++$j) {
      #for(my $x = 4; $x < scalar(@{$cdsTables[$j]}); ++$x) { &DBGR(@{$cdsTables[$j][$x]}); } print STDERR "---\n";
      next if ($cdsTables[$j][3] & 0x8);
      #for(my $x = 4; $x < scalar(@{$cdsTables[$j]}); ++$x) { &DBGR(@{$cdsTables[$j][$x]}); } print STDERR "---\n";
      my @tt = @{$cdsTables[$j]};
      # Pop raw string, left string, right string and flags
      my $rawS = shift @tt; my $leftS = shift @tt; my $rightS = shift @tt; my $flags = shift @tt;

      #Get most possible number of columns
      my $mostPossibleColumns = 0;
      {
        my @numColumns = ();
        for(my $x = 0; $x < scalar(@tt); ++$x) {
          if(not defined $numColumns[scalar(@{$tt[$x]})]) { $numColumns[scalar(@{$tt[$x]})] = 0; }
          else { ++$numColumns[scalar(@{$tt[$x]})]; }
        }
        $mostPossibleColumns = &Argmax(@numColumns);
        #&DBG("mpc:", $mostPossibleColumns);
      }
      #&DBG("tt:", scalar(@tt), scalar(@{$tt[0]}));

      # Pick out the columns with the most possible number of columns
      my @ttt = ();
      {
        my $idx = 0;
        for(my $x = 0; $x < scalar(@tt); ++$x) {
          my $extractOrNot = 0;
          if($mostPossibleColumns == scalar(@{$tt[$x]})) { $extractOrNot = 1; }
          if($flags & 0x4) { if(($mostPossibleColumns-1) == scalar(@{$tt[$x]})){ $extractOrNot = 1; } }
          if(&ProtectTheRowOrNot(@{$tt[$x]}) > 0) { $extractOrNot = 1; }
          if($extractOrNot) {
            @{$ttt[$idx]} = ();
            @{$ttt[$idx]} = @{$tt[$x]};
            ++$idx;
          }
        }
      }
      #&DBG("ttt:", scalar(@ttt), scalar(@{$ttt[0]}));
      #for(my $x = 0; $x < scalar(@ttt); ++$x) { &DBGR(@{$ttt[$x]}); } print STDERR "----\n";

      # Merge expanded row and remove empty columns
      my @ttt1 = &RemoveAlmostEmptyRow(\@ttt);
      #my @ttt1e = &ExpandMultiParagraphRow(\@ttt1);
      #my @ttt2 = &CopyArray(\@ttt1e);
      my @ttt2 = &CopyArray(\@ttt1);
      {
        my $flag = 1;
        while($flag) {
          #for(my $x = 0; $x < scalar(@ttt2); ++$x) { &DBGR(@{$ttt2[$x]}); } print STDERR "-----\n";
          my @ttt2tmp = &MergeExpandedRow(\@ttt2);
          #&DBG("new/old:", scalar(@ttt2tmp), scalar(@ttt2));
          if(scalar(@ttt2tmp) == scalar(@ttt2)) {
            $flag = 0;
          } else {
            @ttt2 = &CopyArray(\@ttt2tmp);
          }
        }
      }
      my @ttt3 = &RemoveEmptyColumn(\@ttt2);
      my $skipLastRow = 0;
      {
        my $missing = 0;
        if(@ttt3 >= 3) {
          my @tmp = @{$ttt3[-1]};
          #&DBGR(@tmp);
          my %expandedCol = ();
          for(my $y = 0; $y < scalar(@tmp); ++$y) {
            if( &HitACurrency($tmp[$y]) ) {
              $tmp[$y]="";
            }
            if(not defined $expandedCol{$tmp[$y]}) {
              if($tmp[$y] eq "") {
                ++$missing;
              } else {
                $expandedCol{$tmp[$y]} = 1;
              }
            } else {
              ++$missing;
              if($expandedCol{$tmp[$y]} == 1) {
                $expandedCol{$tmp[$y]} = 0;
                #++$missing;
              }
            }
          }
          if($missing / scalar(@tmp) >= 0.5) {$skipLastRow=1}
          #&DBG("skipLastRow", $missing, scalar(@tmp));
        }
      }

      # Anchor the information we want to columns
      my $hasSolidHeader = 0;
      my $withReferenceInfo = 0; my $referenceCol = -1; my $hasRating = 0;
      my $withBuyOrSellInfo = 0; my $buyOrSellCol = -1; my $buyOrSell = -1; # -1 not determined, 0 buy, 1 sell
      my $withCounterPartyInfo = 0; my $counterPartyCol = -1;
      my $withCurrencyInfo = 0; my $idvCurrencyCol = 0; my $currencyCol = -1; my $inThousand = 0;
      my $withAmountInfo = 0; my $amountCol = -1; my $amountRow = -1;
      my $localMaxHeaderCol = &Min($maxHeaderCol, scalar(@ttt2)-1);
      my $preReferenceRecord = "";
      if($flags & 0x10) { $hasRating = 1; }
      if(@ttt2 >= 2)
      {
        #&DBGR(@{$ttt2[0]});
        #&DBGR(@{$ttt2[1]});
        {
          my @possibleCol = ();
          for(my $z = 0; $z < $localMaxHeaderCol; ++$z) {
            for(my $y = 0; $y < scalar(@{$ttt2[$z]}); ++$y) {
              if(defined $ttt2[$z][$y] && ($ttt2[$z][$y] =~ /REFERENCE/ || $ttt2[$z][$y] =~ /ISSUER/ ||
                $ttt2[$z][$y] =~ /DELIVERABLE\s+ON\s+DEFAULT/ || $ttt2[$z][$y] =~ /INDEX/ ||
                $ttt2[$z][$y] =~ /TRANCH/)) {
                push @possibleCol, "$z-$y";
              }
            }
          }
          if($withReferenceInfo == 0) {
            foreach my $y (@possibleCol) {
              $y =~ /(\d+)-(\d+)/;
              if(defined $ttt2[$1+1][$2] && $ttt2[$1+1][$2] ne "") {
                $referenceCol = $2;
                #&DBG("Reference entity: ", $referenceCol);
                if($ttt2[$1][$2] =~ /RATING/) {
                  $hasRating = 1;
                  #&DBG("Has rating");
                }
                ++$hasSolidHeader;
                $withReferenceInfo = 1;
                last;
              }
            }
          }
        }
        {
          my @possibleCol = ();
          if($flags & 0x1) {
            if($flags & 0x2) {
              $buyOrSell = 1;
            } else {
              $buyOrSell = 0;
            }
            $withBuyOrSellInfo = 1;
            #&DBG("Context determined buy and sell: ", $buyOrSell);
          } elsif($flags & 0x4) {
            $withBuyOrSellInfo = 1;
          } else {
            for(my $z = 0; $z < $localMaxHeaderCol; ++$z) {
              for(my $y = 0; $y < scalar(@{$ttt2[$z]}); ++$y) {
                if(defined $ttt2[$z][$y] && ($ttt2[$z][$y] =~ /BUY/ || $ttt2[$z][$y] =~ /SELL/)) {
                  push @possibleCol, "$z-$y";
                }
              }
            }
            if($withBuyOrSellInfo == 0) {
              foreach my $y (@possibleCol) {
                $y =~ /(\d+)-(\d+)/;
                if(defined $ttt2[$1+1][$2] && $ttt2[$1+1][$2] ne "") {
                  $buyOrSellCol = $2;
                  ++$hasSolidHeader;
                  $withBuyOrSellInfo = 1;
                  #&DBG("Buy and sell column: ", $buyOrSellCol);
                  last;
                }
              }
            }
          }
        }
        {
          my @possibleCol = ();
          for(my $z = 0; $z < $localMaxHeaderCol; ++$z) {
            for(my $y = 0; $y < scalar(@{$ttt2[$z]}); ++$y) {
              if(defined $ttt2[$z][$y] && (($ttt2[$z][$y] =~ /COUNTER/ && $ttt2[$z][$y] =~ /PAR/) || ($ttt2[$z][$y] =~ /CLEAR/ && $ttt2[$z][$y] =~ /HOUSE/))) {
                 push @possibleCol, "$z-$y";
              }
            }
          }
          if($withCounterPartyInfo == 0) {
            foreach my $y (@possibleCol) {
              $y =~ /(\d+)-(\d+)/;
              if(defined $ttt2[$1+1][$2] && $ttt2[$1+1][$2] ne "") {
                $counterPartyCol = $2;
                #&DBG("Counter party column: ", $counterPartyCol);
                ++$hasSolidHeader;
                $withCounterPartyInfo = 1;
                last;
              }
            }
          }
        }
        {
          my @possibleCurrencyCol = ();
          my @possibleAmountCol = ();
          if($leftS =~ /IN\s+THOUSANDS/) {
            $inThousand = 1;
            #&DBG("Context determined in thousand");
          }
          for(my $z = 0; $z < $localMaxHeaderCol; ++$z) {
            for(my $y = 0; $y < scalar(@{$ttt2[$z]}); ++$y) {
              if(defined $ttt2[$z][$y] && $ttt2[$z][$y] =~ /CURRENCY/) {
                push @possibleCurrencyCol, "$z-$y";
              }
              if(defined $ttt2[$z][$y] && $ttt2[$z][$y] =~ /NOTIONAL/) {
                push @possibleAmountCol, "$z-$y";
                if($ttt2[$z][$y] =~ /000/) {
                  #&DBG("Header determined in thousand");
                  $inThousand = 1;
                }
              }
            }
          }
          #&DBG("possibleAmountCol", @possibleAmountCol);
          if(@possibleCurrencyCol > 0) {
            $idvCurrencyCol = 1;
            if($withCurrencyInfo == 0) {
              foreach my $y (@possibleCurrencyCol) {
                $y =~ /(\d+)-(\d+)/;
                my $row = $1;
                my $col = $2;
                if(defined $ttt2[$row+1][$col] && $ttt2[$row+1][$col] ne "") {
                  $currencyCol = $col;
                  ++$hasSolidHeader;
                  $withCurrencyInfo = 1;
                  #&DBG("Individual currency header: ", $currencyCol);
                  last;
                }
              }
            }
          }
          if($idvCurrencyCol == 0 && $withCurrencyInfo == 0) {
            l1: foreach my $y (@possibleAmountCol) {
              $y =~ /(\d+)-(\d+)/;
              my $row = $1;
              my $col = $2;
              for(my $w = $row+1; $w < @ttt2; ++$w) {
                if(defined $ttt2[$w][$col] && $ttt2[$w][$col] ne "" && &HasACurrency($ttt2[$w][$col]) == 1) {
                  $currencyCol = $col;
                  ++$hasSolidHeader;
                  $withCurrencyInfo = 1;
                  #&DBG("Embedded currency marker 1: ", $y, $currencyCol, $ttt2[$w][$col]);
                  last l1;
                }
              }
            }
          }
          if($idvCurrencyCol == 0 && $withCurrencyInfo == 0) {
            l2: foreach my $y (@possibleAmountCol) {
              $y =~ /(\d+)-(\d+)/;
              my $row = $1;
              my $col = $2;
              for(my $w = $row+1; $w < @ttt2; ++$w) {
                if(defined $ttt2[$w][$col+1] && $ttt2[$w][$col+1] ne "" && &HitACurrency($ttt2[$w][$col+1]) == 1) {
                  $currencyCol = $col+1;
                  ++$hasSolidHeader;
                  $withCurrencyInfo = 1;
                  #&DBG("Embedded currency marker 2: ", $y, $currencyCol, $ttt2[$w+1][$col]);
                  last l2;
                }
              }
            }
          }
          if($idvCurrencyCol == 0 && $withCurrencyInfo == 0) {
            l3: foreach my $y (@possibleAmountCol) {
              $y =~ /(\d+)-(\d+)/;
              my $row = $1;
              my $col = $2;
              for(my $w = $row+1; $w < @ttt2; ++$w) {
                if($col-1>=0 && defined $ttt2[$w][$col-1] && $ttt2[$w][$col-1] ne "" && &HitACurrency($ttt2[$w][$col-1]) == 1) {
                  $currencyCol = $col-1;
                  ++$hasSolidHeader;
                  $withCurrencyInfo = 1;
                  #&DBG("Embedded currency marker 3: ", $y, $currencyCol, $ttt2[$w-1][$col]);
                  last l3;
                }
              }
            }
          }
          if($withAmountInfo == 0) {
            foreach my $y (@possibleAmountCol) {
              $y =~ /(\d+)-(\d+)/;
              my $row = $1;
              my $col = $2;
              if(defined $ttt2[$row+1][$col] && $ttt2[$row+1][$col] ne "") {
                if($ttt2[$row+1][$col] =~ /[\(\)\d,]+/) {
                  $amountCol = $col;
                  $amountRow = $row;
                  ++$hasSolidHeader;
                  $withAmountInfo = 1;
                  #&DBG("Notional amount column: ", $amountCol);
                  last;
                }
              }
            }
          }
          if($withAmountInfo == 0) {
            foreach my $y (@possibleAmountCol) {
              $y =~ /(\d+)-(\d+)/;
              my $row = $1;
              my $col = $2;
              if(defined $ttt2[$row+1][$col+1] && $ttt2[$row+1][$col+1] ne "") {
                if($ttt2[$row+1][$col+1] =~ /[\(\)\d,]+/) {
                  $amountCol = $col+1;
                  $amountRow = $row;
                  ++$hasSolidHeader;
                  $withAmountInfo = 1;
                  #&DBG("Notional amount column: ", $amountCol);
                  last;
                }
              }
            }
          }
          if($withAmountInfo == 0) {
            foreach my $y (@possibleAmountCol) {
              $y =~ /(\d+)-(\d+)/;
              my $row = $1;
              my $col = $2;
              if($col-1>=0 && defined $ttt2[$row+1][$col-1] && $ttt2[$row+1][$col-1] ne "") {
                if($ttt2[$row+1][$col-1] =~ /[\(\)\d,]+/) {
                  $amountCol = $col-1;
                  $amountRow = $row;
                  ++$hasSolidHeader;
                  $withAmountInfo = 1;
                  #&DBG("Notional amount column: ", $amountCol);
                  last;
                }
              }
            }
          }
        }
      }

      if($withReferenceInfo == 1 && $withAmountInfo == 1) {
        my @tttt = &DownfillColumns(\@ttt2, $referenceCol, $amountCol);
        # Show details
        if(0) {
          &DBG("---------------------");
          &DBG("-----------");
          for(my $x = 0; $x < scalar(@tt); ++$x) { &DBGR(@{$tt[$x]}); }
          &DBG("-----------");
          for(my $x = 0; $x < scalar(@ttt); ++$x) { &DBGR(@{$ttt[$x]}); }
          &DBG("-----------");
          for(my $x = 0; $x < scalar(@ttt1); ++$x) { &DBGR(@{$ttt1[$x]}); }
          &DBG("-----------");
          #for(my $x = 0; $x < scalar(@ttt1e); ++$x) { &DBGR(@{$ttt1e[$x]}); }
          #&DBG("-----------");
          for(my $x = 0; $x < scalar(@ttt2); ++$x) { &DBGR(@{$ttt2[$x]}); }
          &DBG("-----------");
          for(my $x = 0; $x < scalar(@ttt3); ++$x) { &DBGR(@{$ttt3[$x]}); }
          &DBG("-----------");
          for(my $x = 0; $x < scalar(@tttt); ++$x) { &DBGR(@{$tttt[$x]}); }
          &DBG("-----------");
          &DBG("Info", $hasSolidHeader, $withReferenceInfo, $withBuyOrSellInfo, $withCounterPartyInfo, $withCurrencyInfo, $withAmountInfo);
          &DBG("Cols", $hasSolidHeader, $referenceCol, $buyOrSellCol, $counterPartyCol, $currencyCol, $amountCol);
          &DBG("Misc", $hasSolidHeader, $hasRating, $buyOrSell, $skipLastRow, $idvCurrencyCol, $inThousand);
          &DBG("Flags", $flags);
          &DBG("---------------------");
        }
        for(my $x = 1; $x < @tttt; ++$x) {
          # See if the next row is a header
          my $rtype = "ITEM";
          my $reason = "";
          my $headerCount = 0;
          if($x+1 < @tttt)
          {
            for(my $y = 0; $y < @{$tttt[$x+1]}; ++$y) {
              foreach my $i (@headerWords) { if($tttt[$x+1][$y] =~ /$i/) {
                  ++$headerCount;
                }
              }
            }
          }
          # Skip Last Row
          if($skipLastRow == 1) { if($x == (scalar(@tttt) - 1)) { $rtype = "SKIP"; $reason = "MAYBE-LASTROW-SUMMARY"; } }
          #if($headerCount > 1 && $skipLastRow == 1) {
          #  my $count = 0;
          #  foreach my $i (@{$tttt[$x]}) {
          #    ++$count if $i ne "";
          #  }
          #  if (($count / scalar(@{$tttt[$x]})) < 0.6) { $rtype = "SKIP"; $reason = "MAYBE-INTABLE-SUMMARY"; }
          #}
          # Currency
          my $currency = "USD";
          if($withCurrencyInfo == 1 && $currencyCol != 0) {
            if($tttt[$x][$currencyCol] ne "") {
              if(&HitACurrency($tttt[$x][$currencyCol])) {
                $currency = $tttt[$x][$currencyCol];
              }
            }
            $currency = "USD" if $currency eq '$';
            $currency = "USD" if $currency eq '';
            $currency = "USD" if $currency =~ /^\s+$/;
          }
          # Notional amount
          my $amount = $tttt[$x][$amountCol];
          $amount =~ s/\(//g; $amount =~ s/\)//g; $amount =~ s/,//g;
          #&DBG("Amount1: ", $amount);
          if($amountCol == $currencyCol) {
            foreach my $y (@possibleCurrencyAry) {
              if($tttt[$x][$amountCol] =~ /\Q$y/) {
                $amount =~ s/\Q$y//;
                $currency = $y;
                $amount =~ s/\s+//g;
                #&DBG("Amount and Currency: ", $tttt[$x][$amountCol], $currency, $amount);
                last;
              }
            }
            #$currency = "USD" if $currency eq '$';
          }
          # In thousand
          if( $amount =~ /(\d+)/) {
            $amount = $1;
            if($globalInThousand || $inThousand) { $amount *= 1000 }
          } else { $rtype = "SKIP"; $reason = "WRONG-AMOUNT"; }
          #&DBG("Amount2: ", $amount);
          # Counter party
          my $counterParty = ".";
          if($withCounterPartyInfo) { $counterParty =  $tttt[$x][$counterPartyCol]; }
          # Reference entity
          my $reference = $tttt[$x][$referenceCol];
          #if("$preReferenceRecord" eq "$reference" && $headerCount > 1) { $rtype = "SKIP"; $reason = "MAYBE-INTABLE-SUMMARY"; }
          # Remove rating
          if($hasRating == 1) {
            $reference =~ s/[\/ ]{1,2}[ABCDWR]+$//;
          }
          # Buy or Sell
          my $buySell = ".";
          if ($withBuyOrSellInfo == 1) {
            if($buyOrSell != -1) {
              if($buyOrSell == 0) { $buySell = "BUY" }
              elsif($buyOrSell == 1) { $buySell = "SELL" }
            } elsif($buyOrSellCol != -1) {
              $buySell = $tttt[$x][$buyOrSellCol];
              $buySell =~ s/\s+//g;
            } elsif ($flags & 0x4) {
              for(my $y = 1; $y <= @{$tttt[$x]}; ++$y) {
                $buySell = $tttt[$x][-$y];
                last if $buySell =~ /SELL|BUY/;
              }
              my $flag = 1; $buySell =~ s/(SELL|BUY)/if($flag){$flag=0;"$1"}else{""}/eg;
            }
          }
          # Formatting
          $reference = &Trim($reference);
          if ($reference eq "") {
            $reference = "."; $rtype = "SKIP"; $reason = "NOREFERENCE";
          }
          $buySell = &Trim($buySell);
          if ($buySell eq "") {
            $buySell = "."; $rtype = "SKIP"; $reason = "NOBUYSELL";
          }
          $currency = &Trim($currency);
          if ($currency eq "") {
            $currency = "."; $rtype = "SKIP"; $reason = "NOCURRENCY";
          }
          $amount = &Trim($amount);
          if ($amount eq "") {
            $amount = "."; $rtype = "SKIP"; $reason = "NOAMOUNT";
          }
          $counterParty = &Trim($counterParty);
          if ($counterParty eq "") {
            $counterParty = "."; $rtype = "SKIP"; $reason = "NOCOUNTERPARTY";
          }
          $preReferenceRecord = $reference;
          if($rtype eq "ITEM") {
            my $basicStr = "$rtype\t$accessNum\t$rptYr\t$rptSeq\t$rptCik\t$rptName\t$rptFileAsOfDate\t$startDate\t$endDate";
            my $infoStr = "$reference\t$buySell\t$currency\t$amount\t$counterParty";
            if ($infoStr !~ /CONTINUED/) {
              push @finalOutputs, "$basicStr\t$infoStr";
              ++$numItem;
            } else {
              $rtype = "ITEM"; $reason = "PROBABLYHEADER";
            }
          }
          if ($rtype eq "SKIP") {
            my $basicStr = "$rtype-$reason\t$accessNum\t$rptYr\t$rptSeq\t$rptCik\t$rptName\t$rptFileAsOfDate\t$startDate\t$endDate";
            my $infoStr = "$reference\t$buySell\t$currency\t$amount\t$counterParty";
            push @finalOutputs, "$basicStr\t$infoStr";
            ++$numSkip;
          }
        }
      }

    }
    foreach my $x (@finalOutputs) {
      print "$x\n";
    }
    #print "META\tACCESSION NUMBER\tREPORTING YEAR\tREPORTING SEQUENCE\tREPORTING CIK\tFUND NAME\tFILE AS OF DATE\tSTART DATE\tEND DATE\tKEYWORDS\n";
    #print "META\t$accessNum\t$rptYr\t$rptSeq\t$rptCik\t$rptName\t$rptFileAsOfDate\t$startDate\t$endDate\tITEMS\t$numItem\n";
    #print "META\tACCESSION NUMBER\tREPORTING YEAR\tREPORTING SEQUENCE\tREPORTING CIK\tFUND NAME\tFILE AS OF DATE\tSTART DATE\tEND DATE\tKEYWORDS\n";
    #print "META\t$accessNum\t$rptYr\t$rptSeq\t$rptCik\t$rptName\t$rptFileAsOfDate\t$startDate\t$endDate\tSKIPS\t$numSkip\n";
  }
}

# Load the whole file into a string and remove the trailing newlines
for(my $fid = 0; $fid < @ARGV; ++$fid)
{
  $currentFN = "$ARGV[$fid]";
  my $prefixFN = $currentFN;
  $prefixFN =~ s/.gz$//;
  if( -e "$prefixFN.bin") {
     my $fulltextRef = retrieve("$prefixFN.bin");
     $fulltext = $$fulltextRef;
  }
  else
  {
    open my $fh, "gzip -fdc '$ARGV[$fid]' |" or warn "Failed to open $ARGV[$fid]\n";
    $/ = undef;
    $fulltext = <$fh>;
    $fulltext = uc($fulltext);
    $fulltext =~ s/ {2,}/ /g; # Collapse multi spaces to a space
    $fulltext =~ s/\t+/  /g; # Convert tabs to double space
    $fulltext =~ s/<BR>/\n/g;
    $fulltext =~ s/\n+/   /g; # Convert a newline to 3 spaces
    # Expand colspan
    $fulltext =~ s/<TD([^>]*?)COLSPAN="?(\d+)"?([^>]*?)>(.*?)<\/TD>/"<TD $1$3>$4<\/TD>"x$2/eg;
    $fulltext =~ s/&NBSP;/ /g; $fulltext =~ s/&#160;/ /g;
    $fulltext =~ s/&REG;/®/g; $fulltext =~ s/&AMP;/&/g;
    $fulltext =~ s/&#036;/\$/g; $fulltext =~ s/&POUND;/GBP/g; $fulltext =~ s/&#163;/GBP/g; $fulltext =~ s/&EURO;/EUR/g; $fulltext =~ s/&#8346;/EUR/g;
    $fulltext =~ s/&#151;/-/g; $fulltext =~ s/&#150;/-/g;
    $fulltext =~ s/&#149;//g; $fulltext =~ s/&#134;//g; $fulltext =~ s/&#8212;/-/g;
    $fulltext =~ s/&#145;/'/g; $fulltext =~ s/&#146;/'/g; $fulltext =~ s/&#8217;/'/g;
    $fulltext =~ s/&#147;/"/g; $fulltext =~ s/&#148;/"/g;
    $fulltext =~ s/<(\w+).*?>/<$1>/g; # Clean tag parameters
    foreach my $i ("FONT", "I", "U", "B", "PAGE") {
      while($fulltext=~/<$i.*?>(.*?)<\/$i>/) {
        $fulltext =~ s/<$i.*?>(.*?)<\/$i>/$1/g;
      }
    }
    foreach my $i ("SUP", "SUB") {
      while($fulltext=~/<$i.*?>(.*?)<\/$i>/) {
        $fulltext =~ s/<$i.*?>(.*?)<\/$i>//g;
      }
    }
    foreach my $i ("P") {
      while($fulltext=~/<$i.*?>(.*?)<\/$i>/) {
        $fulltext =~ s/<$i.*?>(.*?)<\/$i>/    $1/g; # Paragraph to 4 spaces
      }
    }
    $fulltext =~ s/(.{500}CONTINUED.{500})/my $s=&RemoveDualTableInterval($1); "$s"/eg;
    $fulltext =~ s/(.{500})CONTINUED/my $s=&RemoveTableInterval($1); "${s}CONTINUED"/eg;
    $fulltext =~ s/(.{100}<HR>.{200})/my $s=&RemoveTableIntervalWithTagWithoutWords($1,"CONTINUED", "CDS CONTRACTS", "SWAP CONTRACTS"); "$s"/eg;
    store(\$fulltext, "$prefixFN.bin");
    close $fh;
  }
  &Run();
}

0;

