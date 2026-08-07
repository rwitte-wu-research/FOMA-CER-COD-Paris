# =============================================================================
# R/18_fig2_prisma.R -- Figure 2: PRISMA 2020 two-wave flow (FOMA CER-COD-Paris)
# Sources (canonical, hub K-ruling 2026-08-07): docs/search_protocol_2026-07.md
# (identification stage) + frozen S7.2 revision (dedup split 22 within / 828
# across; wave-1 boxes F5-Q4; closing box F5-Q3). Paths relative to the project
# root (RStudio route: setwd + source(".Rprofile") first). Outputs:
# output/figures/fig2_prisma.pdf + .png.
# =============================================================================
stopifnot(986+1033+837==2856, 22+828==850, 2856-850==2006, 146+25+49==220,
          2006-220-66==1720, 66+59==125, 125-5==120, 61+59==120, 43+17==60)
library(grid)
box <- function(x,y,w,h,lab,cex=0.60,fill="white",lty="solid"){
  grid.roundrect(x=unit(x,"npc"),y=unit(y,"npc"),width=unit(w,"npc"),
    height=unit(h,"npc"),r=unit(1.2,"mm"),gp=gpar(fill=fill,lwd=1,lty=lty))
  grid.text(lab,x=unit(x,"npc"),y=unit(y,"npc"),gp=gpar(cex=cex,lineheight=0.95))}
arr <- function(x1,y1,x2,y2) grid.lines(x=unit(c(x1,x2),"npc"),
    y=unit(c(y1,y2),"npc"),arrow=arrow(length=unit(2,"mm"),type="closed"),
    gp=gpar(lwd=1,fill="black"))
draw <- function(){
  grid.newpage()
  grid.text("Wave 1 (2021/22) \u2014 reported qualitatively",x=.16,y=.975,gp=gpar(cex=.66,fontface="bold"))
  grid.text("Wave 2 (June\u2013July 2026) \u2014 AI-assisted",x=.52,y=.975,gp=gpar(cex=.66,fontface="bold"))
  w1 <- c("(i) Screening of prior reviews\n(seed list, Appendix Table A.5)",
          "(ii) Keyword searches in academic\ndatabases (strings not reported)",
          "(iii) Title-and-abstract screening",
          "(iv) Forward and backward\ncitation tracking",
          "(v) Full-text assessment against\npre-specified eligibility criteria")
  y1 <- seq(.90,.42,length.out=5)
  for(i in 1:5){box(.16,y1[i],.26,.075,w1[i]); if(i<5) arr(.16,y1[i]-.0375,.16,y1[i+1]+.0375)}
  box(.16,.30,.26,.06,"Stage-level counts not retained\n(PRISMA-2020); see Section 3.1",cex=.55,lty="dashed")
  w2 <- c("Records identified n = 2,856\n(Scopus 986 \u00b7 Web of Science 1,033 \u00b7 EBSCO 837)",
          "Duplicates removed n = 850\n(22 within-database \u00b7 828 across databases)",
          "Unique records n = 2,006",
          "Rule-based screens excluded n = 220\n(no COD term 146 \u00b7 no CER term 25 \u00b7 doc type 49)",
          "Corpus rematch, record level n = 66",
          "Title/abstract screening n = 1,720",
          "Excluded at title/abstract n = 972",
          "Include candidates n = 647 \u00b7 FLAG n = 101",
          "Corpus rematch, candidate level n = 155\n(cross-channel, consolidated)",
          "Identified, not extracted n = 593\n(70% 2024\u20132026; extraction cutoff, DEC-041)")
  y2 <- seq(.915,.180,length.out=10)
  for(i in 1:10){box(.52,y2[i],.32,.062,w2[i],cex=.55); if(i<10) arr(.52,y2[i]-.031,.52,y2[i+1]+.031)}
  sn <- c("AI-assisted supplementary channel:\n83 records \u2192 50 downloads\n(40 published \u00b7 10 WP);\n4 already in corpus \u00b7 29 other classes",
          "Google-Scholar snowballing\n(separate identification line)",
          "148 pre-2020 records screened\n(no date restriction)",
          "Retrievability benchmark: 43/60\n(Scopus 38 \u00b7 WoS 40 \u00b7 EBSCO 24)")
  ys <- c(.84,.66,.50,.32)
  for(i in 1:4){box(.875,ys[i],.21,.085,sn[i],cex=.52,lty="dashed")
    grid.lines(x=unit(c(.77,.68),"npc"),y=unit(c(ys[i],ys[i]),"npc"),gp=gpar(lty="dotted"))}
  box(.50,.065,.72,.075,paste0("Included studies n = 125 (wave 1: 66 \u00b7 wave 2: 59)  \u2192  ",
      "harmonisation exits n = 5  \u2192  contributing corpus n = 120 (wave 1: 61 \u00b7 wave 2: 59)"),cex=.62,fill="grey95")
  arr(.16,.27,.30,.10); arr(.52,.149,.52,.103)
}
outdir <- file.path("output","figures")
dir.create(outdir, showWarnings = FALSE, recursive = TRUE)
cairo_pdf(file.path(outdir,"fig2_prisma.pdf"), width=11.7, height=8.3); draw(); dev.off()
png(file.path(outdir,"fig2_prisma.png"), width=11.7, height=8.3, units="in", res=300, type="cairo"); draw(); dev.off()
cat("[R18 DONE] fig2_prisma.pdf/.png written; box sums asserted\n")
