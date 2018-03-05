install.packages("plyr")
install.packages("dplyr")
install.packages("tidyr")
install.packages("readr")
install.packages("forcats")

# load packages
library(ggplot2)
library(plyr)
library(dplyr)
library(tidyr)
csv <- read.csv('test_sim_2.csv')
library(readr) # for import
library(forcats) # for factors

# read in data
test_sim <- read_csv('/Users/alexandrasalem/Documents/test_sim_2.csv', # safer, StringsAsFactors = FALSE by default
                     col_types = cols(
                       dx = col_factor(levels = NULL))
) 


# add dx category for humans to interpret
test_sim <- test_sim %>% 
  mutate(dx_cat = fct_recode(dx, asd = "1", td = "2")) # forcats used here

# get mean similarity scores by gold standard (gs) and dx_cat
test_sim %>% 
  group_by(gs, dx_cat) %>% 
  summarize_at(vars(sim), mean)

# make plots, I think we are just plotting the means + 95% bootstrapped CIs?
ggplot(test_sim, aes(x = dx_cat, y = sim)) +
  stat_summary(fun.data = "mean_cl_boot", geom = "pointrange") +
  facet_wrap(~gs)

