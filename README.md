![alt text](Website/images/news.svg)

# Understandng Financial Reports using Natural Processing


## Background

This project investigates how mutual funds leverage credit derivative by studying their routine filings to the U.S. Securities and Exchange Commission. Instead of studying all credit derivatives, we focus on Credit Default Swap (CDS), one of the popular credit derivatives that were considered the culprit of the 2007-2008 financial crisis. CDS is traded over-the-counter, thus there exists little public information on its trading activities for the outside investors. However, such information is valuable. CDS is designed as a hedging tool that the buyers use to protect themselves from potential default events of the reference entity. Besides, it is also used for speculation and liquidity management especially during a crisis.

Mutual funds are required to report their portfolio holdings to the SEC each quarter in reports using the Form N-Q (the 1st and the 3rd fiscal quarter) and the Form N-CSR (the 2nd and the 4th fiscal quarter). Both forms are filed at one level below the fund family, i.e., the “series trust” or the “shared trust” level. A series trust is a legal entity comprise a cluster of independently managed funds that have the same sponsor, share distribution and branding efforts, and often a unitary (or overlapping) board.

Before SEC has requested more frequent and detailed fund holdings reporting at the end of 2016, mutual funds filed the forms in discrepant formats. One can simply imagine the difficulty of effectively extracting information from the reports for carrying out further analysis. There exist some previous studies that explored how mutual funds have made use of CDS (Adam and Guttler, 2015, Jiang and Zhu, 2016), but only examined a fraction of institutions over a short period of time. In this project, we aim to extract as much CDS-related information as possible from all the filings available to date to enable more thorough downstream analysis. This information appears not only in the form of charts but also in words, thus Natural Language Processing (NLP) is the key.






## Authors: 

[Tarun Sudhams](https://github.com/sudhamstarun)
[Varun Vamsi](https://github.com/Varunvamsi)
