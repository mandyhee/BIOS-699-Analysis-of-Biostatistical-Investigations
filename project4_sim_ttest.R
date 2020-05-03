# +++++++++ Project 4 Power Analysis for Needle Biopsy Deflection in Prostate Cancer Patients ++++++++
# First simulation design: one sample t test seperate from random and target tissue: difference between std and new needle

# distribution for standard needle is fixed
# Hypothesis
# H0 mean(new_needle) - mean(standard_needle) = 0.4*mean(standard_needle)
# H1 mean(new_needle) - mean(standard_needle) > 0.4*mean(standard_needle)

set.seed(100)

# load library -------------------
library(doParallel)
library(tidyverse)

# empty matrix to store power result --------------
reject_random_matrix = matrix(NA, nrow = 7, ncol = 7)
reject_target_matrix = matrix(NA, nrow = 7, ncol = 7)

rownames(reject_random_matrix) = c(50, seq( 100, 600, 100))
colnames(reject_random_matrix) = seq(0.4, 0.7, 0.05)

rownames(reject_target_matrix) = c(50, seq( 100, 600, 100))
colnames(reject_target_matrix) = seq(0.4, 0.7, 0.05)

# empty matrix to store number of random and targeted tissue ------------
number_random_matrix = matrix(NA, nrow = 7, ncol = 7)
number_target_matrix = matrix(NA, nrow = 7, ncol = 7)

rownames(number_random_matrix) = c(50, seq( 100, 600, 100))
colnames(number_random_matrix) = seq(0.4, 0.7, 0.05)

rownames(number_target_matrix) = c(50, seq( 100, 600, 100))
colnames(number_target_matrix) = seq(0.4, 0.7, 0.05)


# needle defects reduction -------------
r_seq = seq(0.4, 0.7, 0.05)

# number of needles ---------
N_seq = c(50, seq( 100, 600, 100))

# correlation (test 0, 0.25, 0.5)------------
rho = 0.50

# null hypothesis -------------
mu_random = 0.4*1.34
mu_target = 0.4*10.6

# start simulation --------------
system.time({
  # Find out how many cores are available: 
  # detectCores()
  # Create cluster with desired number of cores: 
  cl = makeCluster(4)
  # Register cluster: 
  registerDoParallel(cl)
  # Find out how many cores are being used
  getDoParWorkers()
  
  # loop thourgh r_seq and N_seq ----------
  for (ri in 1:length(r_seq)){
    r = r_seq[ri]
    # create data for each reduction rate
    random_diff_data = rnorm(n = 2300000, mean = 1.34*r, sd = sqrt(1.22**2 + 1.52**2 -2*rho*1.22*1.52))
    target_diff_data = rnorm(n = 2300000, mean = 10.6*r, sd = sqrt(1.22**2 + 1.52**2 -2*rho*1.22*1.52))
    
    print(r)
    
    for (Nj in 1:length(N_seq)){
      N = N_seq[Nj]
      print(N)
      
      # empty vector to store simlulated results for each simulation
      sim_random_result = NULL
      sim_target_result = NULL
      
      # empty vector to store number of random and targeted tissue for each simulation
      sim_random_number = NULL
      sim_target_number = NULL
      
      # number of simulations
      sims = 500
      for (i in 1:sims){
        # create data for each simulation ------------- 
        # balanced amount of new and standard needle
        num_patient = 1
        cum_new_needle = 0
        cum_std_needle = 0
        tdata = NULL
        while (cum_new_needle <= N){
          
          num_of_lesion = sample(c(1,2,3),1)
          num_of_target = num_of_lesion*4
          num_of_random = 12
          total_needle_per_patient = num_of_target + num_of_random
          cum_new_needle = cum_new_needle + total_needle_per_patient/2
          cum_std_needle = cum_std_needle + total_needle_per_patient/2
          
          if(cum_new_needle > N){
            break
          }
          tdata = bind_rows(tdata, 
                            bind_cols(
                              num_patient=num_patient, 
                              num_of_lesion=num_of_lesion, 
                              num_of_target = num_of_target,
                              num_of_random = 12,
                              total_needle_per_patient= total_needle_per_patient, 
                              cum_new_needle = cum_new_needle, 
                              cum_std_needle = cum_std_needle
                            ))
          
          
          num_patient = num_patient + 1
          
        }
        
        # count number of needles ------------
        tot_target = sum(tdata$num_of_target)
        num_needle_per = tdata$cum_std_needle[dim(tdata)[1]]
        target_needle = tot_target/2
        random_needle = num_needle_per-tot_target/2
        

        # sample diff from random and target data data -----------
        random_diff = sample(random_diff_data, random_needle)
        target_diff = sample(target_diff_data, target_needle)
        
        # perform one sample t test ----------
        random_t = t.test(random_diff, mu = mu_random, alternative = "greater")
        target_t = t.test(target_diff, mu = mu_target, alternative = "greater")
        
        # store ttest result in vector ----------
        sim_random_result = c(sim_random_result,  random_t$p.value)
        sim_target_result = c(sim_target_result, target_t$p.value)
        
        # store number of random and target tissue
        sim_random_number = c(sim_random_number, random_needle)
        sim_target_number = c(sim_target_number, target_needle)
        
      }
      
      # test power -----------
      random_reject = sum(sim_random_result < 0.05)
      target_reject = sum(sim_target_result < 0.05)
      print(random_reject)
      print(target_reject)
      
      # take average of random and targeted tissues for each N and r -----------
      avg_random = mean(sim_random_number)
      avg_target = mean(sim_target_number)
      
      # store power result in matrix -------------
      reject_random_matrix[Nj,ri] = random_reject
      reject_target_matrix[Nj,ri] = target_reject
      
      # store average number of random and target tissues ---------
      number_random_matrix[Nj,ri] = avg_random
      number_target_matrix[Nj,ri] = avg_target
      
      
    }
  }
  
  
  stopCluster(cl)
  registerDoSEQ()
  
})



# random tissue result -----------
reject_random_matrix1 = apply(reject_random_matrix, 2,as.numeric)
number_random_mean = apply(number_random_matrix, 1, mean)
number_random_sd = apply(number_random_matrix, 1, sd)

df_random = data.frame(N = rep(c(0,number_random_mean),7),
                       rho = rep(rho, 56),
                       r = c(rep(0.40, 8), rep(0.45, 8), rep(0.50, 8), rep(0.55, 8), rep(0.60, 8), 
                             rep(0.65, 8), rep(0.70, 8)),
                       reject = as.numeric(c(0, reject_random_matrix1[,1], 0, reject_random_matrix1[,2], 0, reject_random_matrix1[,3],
                                             0, reject_random_matrix1[,4], 0, reject_random_matrix1[,5], 0, reject_random_matrix1[,6],
                                             0, reject_random_matrix1[,7])))
df_random$reject = (df_random$reject/10000)*100


#df_random = read.csv(file = "./project4/one sample ttest (test diff)/random_ttest_diff_sim10000.csv")


# plot random -------------
ggplot(data = df_random, aes(x=N, y=reject)) + 
  geom_smooth(aes(group=factor(r), color = factor(r)), se = FALSE) +
  geom_hline(yintercept = 80, linetype = "dashed") + 
  geom_vline(xintercept = number_random_mean[6], linetype = "dashed") + 
  scale_y_continuous(name = "Pr(reject)", limits = c(0,100), breaks = seq(0, 100, 20)) +
  scale_x_continuous(name = "Average number of new needles in random biopsies across simulations",
                     limits = c(0, max(number_random_mean)), 
                     breaks = round(as.numeric(number_random_mean), digits = 0)) +
  labs(color = "Reduction") +
  ggtitle("Random tissue: difference in deflection (one sample t test)")



# target tissue result ----------
reject_target_matrix1 = apply(reject_target_matrix, 2,as.numeric)

number_target_mean = apply(number_target_matrix, 1, mean)
number_target_sd = apply(number_target_matrix, 1, sd)

#df_target = read.csv(file = "./project4/one sample ttest (test diff)/target_ttest_diff_rho0.5_sim10000.csv")
df_target = data.frame(N = rep(c(0, number_target_mean),7),
                       r = c(rep(0.40, 8), rep(0.45, 8), rep(0.50, 8), rep(0.55, 8), rep(0.60, 8), 
                             rep(0.65, 8), rep(0.70, 8)),
                       reject = as.numeric(c(0, reject_target_matrix1[,1], 0, reject_target_matrix1[,2], 0, reject_target_matrix1[,3],
                                             0, reject_target_matrix1[,4], 0, reject_target_matrix1[,5], 0, reject_target_matrix1[,6],
                                             0, reject_target_matrix1[,7])))
df_target$reject = (df_target$reject/10000)*100

# plot target ----------
ggplot(data = df_target, aes(x=N, y=reject)) + 
  geom_smooth(aes(group=factor(r), color = factor(r)), se = FALSE) +
  geom_hline(yintercept = 80, linetype = "dashed") + 
  geom_vline(xintercept = number_target_mean[6], linetype = "dashed") + 
  scale_y_continuous(name = "Pr(reject)",limits = c(0,100), breaks = seq(0, 100, 20)) +
  scale_x_continuous(name = "Average number of new needles in targeted biopsies across simulations", 
                     limits = c(0, max(number_target_mean)), 
                     breaks =  round(as.numeric(number_target_mean), digits = 0)) +
  labs(color = "Reduction") +
  ggtitle("Target tissue difference in deflection (one sample t test)")

write.csv(as.data.frame(df_random), "~/Desktop/WINTER2020/BIOS699/project4/random_ttest_diff_rho0.5_sim10000.csv", row.names = F)
write.csv(as.data.frame(df_target), "~/Desktop/WINTER2020/BIOS699/project4/target_ttest_diff_rho0.5_sim10000.csv", row.names = F)


