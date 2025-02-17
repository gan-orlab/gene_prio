library(data.table)

#load data
locus <- fread("../locus/gwas_locus_hg19_genes.tab")
locus <- locus[,c("symbol","locus")]

CALB1_CALCR <- fread("CALB1_CALCR.txt")
CALB1_CRYM_CCDC68 <- fread("CALB1_CRYM_CCDC68.txt")
CALB1_GEM <- fread("CALB1_GEM.txt")
CALB1_PPP1R17 <- fread("CALB1_PPP1R17.txt")
CALB1_RBP4 <- fread("CALB1_RBP4.txt")
CALB1_TRHR <- fread("CALB1_TRHR.txt")
SOX6_AGTR1 <- fread("SOX6_AGTR1.txt")
SOX6_DDT <- fread("SOX6_DDT.txt")
SOX6_GFRA2 <- fread("SOX6_GFRA2.txt")
SOX6_PART1 <- fread("SOX6_PART1.txt")

#Merge data
result <- Reduce(function(x, y) merge(x, y, by = "symbol", all.x = T), list(locus,
                                                                                                                                                CALB1_CALCR,
                                                                                                                                                CALB1_CRYM_CCDC68,
                                                                                                                                                CALB1_GEM,
                                                                                                                                                CALB1_PPP1R17,
                                                                                                                                                CALB1_RBP4,
                                                                                                                                                CALB1_TRHR,
                                                                                                                                                SOX6_AGTR1,
                                                                                                                                                SOX6_DDT,
                                                                                                                                                SOX6_GFRA2,
                                                                                                                                                SOX6_PART1))


                 
#set NA to 0
result[is.na(result)] <- 0

write.table(result, "AGTR1_da_mean_expression.txt", quote = F, row.names = F, sep = "\t")

#Create neighborhood scores
final22 <- result
final2_subset.list <- lapply(sort(unique(final22$locus)), function(i){
                final2 <- subset(final22, locus == i)
                colnames(final2) <- paste0(colnames(final2),"_NBH")
                if(nrow(final2) == 1){
                        final3 <- final2[,3:(ncol(final2)-1)]
                        final3[final3 > 0] <- 1
                        return(data.frame(symbol = final2$symbol,final3, locus = final2$locus))
                }
                final3 <- apply(final2[,3:(ncol(final2)-1)], 2, function(i){
                        abs(i)/max(abs(i))
                })
                return(data.frame(symbol = final2$symbol,final3, locus = final2$locus))
})

is.nan.data.frame <- function(x)
do.call(cbind, lapply(x, is.nan))


final3 <- Reduce(rbind, final2_subset.list)
final3[is.nan(final3)] <- 0


write.table(final3, "AGTR1_da_mean_expression_nbh.txt", quote = F, row.names = F, sep = "\t")
