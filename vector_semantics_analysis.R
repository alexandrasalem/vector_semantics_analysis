#install.packages("plyr")
#install.packages("dplyr")
#install.packages("tidyr")
#install.packages("readr")
#install.packages("forcats")
#install.packages("Hmisc")

# load packages
library(ggplot2)
library(plyr)
library(dplyr)
library(tidyr)
library(readr) # for import
library(forcats) # for factors
library(Hmisc)

# read in data
test_sim <- read_csv('ERPA_similarity_gs1.csv', # safer, StringsAsFactors = FALSE by default
                     col_types = cols(
                       dx = col_factor(levels = NULL))
) 


# add dx category
#test_sim <- test_sim %>% 
#  mutate(dx_cat = fct_recode(dx, asd = "ALN", asd = "ALI", td = "SLI", td = "TD")) # forcats used here

# get mean similarity scores by gold standard (gs) and dx_cat
test_sim %>% 
  group_by(gs, dx) %>% 
  summarize_at(vars(sim), mean)

# make plots

#This one shows the 95% confidence intervals for TD kids, varying TD gold standards
ggplot(filter(test_sim, dx=="TD", gs_dx == "TD"), aes(x = gs, y = sim)) +
  stat_summary(fun.data = "mean_cl_boot", geom = "pointrange") +
  #xlim(0.950, 1.00) +
  labs(x = "Gold Standard Choice") +
  labs(y = "Semantic Similarity \n to Gold Standards") +
  ggtitle("Semantic Similarity Between TD participants \n and TD Gold Standards", subtitle = "95% Confidence Intervals") +
  theme(axis.text.x=element_blank(),
        axis.ticks.x=element_blank(),
        plot.title=element_text(hjust=.5),
        plot.subtitle = element_text(hjust=.5))

ggsave("td_vs_td_gs1.pdf", last_plot())

#This one shows the 95% confidence intervals for ASD kids, varying ASD gold standards
ggplot(filter(test_sim, dx=="ASD", gs_dx == "ASD"), aes(x = gs, y = sim)) +
  stat_summary(fun.data = "mean_cl_boot", geom = "pointrange") +
  labs(x = "Gold Standard Choice") +
  labs(y = "Semantic Similarity \n to Gold Standards") +
  ggtitle("Semantic Similarity Between ASD participants \n and ASD Gold Standards", subtitle = "95% Confidence Intervals") +
  theme(axis.text.x=element_blank(),
        axis.ticks.x=element_blank(),
        plot.title=element_text(hjust=.5),
        plot.subtitle = element_text(hjust=.5))
  
ggsave("asd_vs_asd_gs1.pdf", last_plot())

#This one shows the 95% confidence intervals for TD kids and ASD kids side by side, varying TD gold standards
ggplot(filter(test_sim, gs_dx == "TD", dx!="SLI"), aes(x=gs, y=sim)) +
  stat_summary(fun.data = "mean_cl_boot", geom="pointrange", size=.25) +
  facet_wrap(~dx) +
  labs(x = "Gold Standard Choice") +
  labs(y = "Semantic Similarity \n to Gold Standards") +
  ggtitle("Semantic Similarity Between TD and ASD participants \n and TD Gold Standards", subtitle = "95% Confidence Intervals") +
  theme(axis.text.x=element_blank(),
        axis.ticks.x=element_blank(),
        plot.title=element_text(hjust=.5),
        plot.subtitle = element_text(hjust=.5),
        aspect.ratio = .7
        )

ggsave("td_and_asd_vs_td_gs1.pdf", last_plot())

#This one shows the 95% confidence intervals for TD kids and ASD, varying gold standard, overlayed and in color
ggplot() +
  stat_summary(data = filter(test_sim, gs_dx == "ASD", dx=="TD"), fun.data = "mean_cl_boot", geom="pointrange", size = .25, aes(color = "TD")) +
  stat_summary(data = filter(test_sim, gs_dx == "ASD", dx=="ASD"), fun.data = "mean_cl_boot", geom="pointrange", size = .25, aes(color = "ASD")) +
  aes(x=gs, y=sim) +
  scale_colour_manual(name = 'Diagnoses',values=c(alpha("red", .4),alpha("blue", .4))) +
  labs(x = "Gold Standard Choice") +
  labs(y = "Semantic Similarity \n to Gold Standards") +
  ggtitle("Semantic Similarity Between ASD participants \n and ASD Gold Standards", subtitle = "95% Confidence Intervals") +
  theme(axis.text.x=element_blank(),
        axis.ticks.x=element_blank(),
        plot.title=element_text(hjust=.5),
        plot.subtitle = element_text(hjust=.5))


ggsave("td_and_asd_vs_asd_gs1_overlayed.pdf", last_plot())

#This one shows the 95% confidence intervals for TD kids and ASD, varying ASD gold standard
ggplot(filter(test_sim, gs_dx == "ASD", dx!="SLI"), aes(x=gs, y=sim)) +
  stat_summary(fun.data = "mean_cl_boot", geom="pointrange", size = .25) +
  labs(x = "Gold Standard Choice") +
  labs(y = "Semantic Similarity \n to Gold Standards") +
  ggtitle("Semantic Similarity Between TD and ASD participants \n and ASD Gold Standards", subtitle = "95% Confidence Intervals") +
  theme(axis.text.x=element_blank(),
        axis.ticks.x=element_blank(),
        plot.title=element_text(hjust=.5),
        plot.subtitle = element_text(hjust=.5),
        aspect.ratio = .7
  )
ggsave("td_and_asd_vs_asd_gs1.pdf", last_plot())

#This one shows the 95% confidence intervals for TD kids and ASD kids similarity values, for a chosen Gold Standard
ggplot(filter(test_sim, gs=="OGI-001", dx!="SLI"), aes(x=dx, y=sim)) +
  stat_summary(fun.data = "mean_cl_boot", geom="pointrange") +
  labs(x = "Diagnostic Group") +
  labs(y = "Semantic Similarity \n to Gold Standards") +
  ggtitle("Semantic Similarity Between Diagnostic Groups \n and a Chosen Gold Standard", subtitle = "95% Confidence Intervals") +
  theme(plot.title=element_text(hjust=.5),
        plot.subtitle = element_text(hjust=.5))

ggsave("td_and_asd_vs_OGI-001_gs1.pdf", last_plot())

#This one shows the 95% confidence intervals for TD kids and ASD kids similarity values, for various chosen Gold Standards
#To pick which gold standards, edit the filter function (gs == c()) for whichever participants you want to make the gold standard and change the labeller argument to match those choices
ggplot(filter(test_sim, gs==c("OGI-001", "OGI-005", "OGI-007"), dx!="SLI"), aes(x=dx, y=sim)) +
  stat_summary(fun.data = "mean_cl_boot", geom="pointrange") +
  facet_wrap(~gs, labeller = as_labeller(c("OGI-001"="Gold Standard 1", "OGI-005"="Gold Standard 2", "OGI-007" = "Gold Standard 3"))) +
  labs(x = "Diagnostic Group") +
  labs(y = "Semantic Similarity \n to Gold Standards") +
  ggtitle("Semantic Similarity Between Diagnostic Groups \n and Three Different Gold Standards", subtitle = "95% Confidence Intervals") +
  theme(plot.title=element_text(hjust=.5),
        plot.subtitle = element_text(hjust=.5))

ggsave("td_and_asd_vs_OGI-001-005-007_gs1.pdf", last_plot())

#This is a histogram where the x axis is similarity and the y axis is percent of 
ggplot(filter(test_sim, gs == "OGI-001", dx!="SLI"))+
  geom_histogram(aes(x=sim, y = (y = (..count..)/tapply(..count..,..PANEL..,sum)[..PANEL..])), binwidth=.001, fill = "white", colour = "black") +
  scale_y_continuous(labels=scales::percent) +
  facet_wrap(~dx) +
  labs(x = "Semantic Similarity") +
  labs(y = "Percentage of Participants") +
  ggtitle("Histogram of Variation in Average Semantic Similarity \n to a Gold Standard Across Diagnostic Groups") +
  theme(plot.title=element_text(hjust=.5),
        plot.subtitle = element_text(hjust=.5))

ggsave("td_and_asd_sim_hist_OGI-001.pdf", last_plot())

#Alison's orig:
ggplot(test_sim, aes(x=dx_cat, y=sim)) +
  stat_summary(fun.data = "mean_cl_boot", geom = "pointrange")+
  facet_wrap(~gs)

