autoParse <- function(x){
  paste(c(input, as.character(masterIndex$EDGAR_LINK[x])), collapse = "") %>% # Step 1
  readLines(encoding = "UTF-8") %>% # Step 2
  str_c(collapse = " ") %>% # Step 3
  str_extract(pattern = "(?s)(?m)<TYPE>10-K.*?(</TEXT>)") %>% # Step 4
  str_replace(pattern = "((?i)<TYPE>).*?(?=<)", replacement = "") %>% # Step 5
  str_replace(pattern = "((?i)<SEQUENCE>).*?(?=<)", replacement = "") %>% # Step 6
  str_replace(pattern = "((?i)<FILENAME>).*?(?=<)", replacement = "") %>%
  str_replace(pattern = "((?i)<DESCRIPTION>).*?(?=<)", replacement = "") %>%
  str_replace(pattern = "(?s)(?i)<head>.*?</head>", replacement = "") %>%
  str_replace(pattern = "(?s)(?i)<(table).*?(</table>)", replacement = "") %>%
  str_replace_all(pattern = "(?s)(?i)(?m)> +Item|>Item|^Item", replacement = ">°Item") %>% # Step 7
  str_replace_all(pattern = "(?s)<.*?>", replacement = " ") %>% # Step 8
  str_replace_all(pattern = "&(.{2,6});", replacement = " ") %>% # Step 9
  str_replace_all(pattern = "(?s) +", replacement = " ") %>% # Step 10
  write(file = paste(output, x, ".txt"), sep = "") # Step 11
}