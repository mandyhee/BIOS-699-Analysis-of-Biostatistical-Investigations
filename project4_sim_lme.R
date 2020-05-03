# +++++++++ Project 4 Power Analysis for Needle Biopsy Deflection in Prostate Cancer Patients ++++++++
# Second simulation design: multivariate linear regression with GEE, use wald test to test coefficient difference
# Hypothesis:
# H0: expected beta = estimated beta (for needle defect reduction)
# H1: expected beta not equal to estimated beta (for needle defect reduction)

# load library -----------------------------
library(tidyverse)
library(nlme)
library(geepack)
library(doBy)
library(doParallel)

# empty matrix to store result --------------
reject_random_matrix = matrix(NA, nrow = 7, ncol = 7)
reject_target_matrix = matrix(NA, nrow = 7, ncol = 7)

rownames(reject_random_matrix) = c(50, seq( 100, 600, 100))
colnames(reject_random_matrix) = seq(0.4, 0.7, 0.05)

rownames(reject_target_matrix) = c(50, seq( 100, 600, 100))
colnames(reject_target_matrix) = seq(0.4, 0.7, 0.05)

# empty matrix to store number of random and targeted tissue -----------
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


#cov_mat = matrix(c(0.22**2, rho*0.16*0.22, rho*0.16*0.22, 0.16**2), 2, 2)
#std_random_data = rnorm(n = 20000, mean = 1.34, sd = 1.22)
#std_target_data = rnorm(n = 20000, mean = 10.6, sd = 1.52)
# std_data = mvrnorm(n = 20000, mu = c(1.34, 10.6), Sigma = cov_mat)


# null hypothesis for wald test -------------
beta1_H0 = -0.536 # -1.34*0.4
beta1_3_H0 = -4.24 # -10.6*0.4


system.time({
  # Find out how many cores are available: 
  # detectCores()
  # Create cluster with desired number of cores: 
  cl = makeCluster(4)
  # Register cluster: 
  registerDoParallel(cl)
  # Find out how many cores are being used
  getDoParWorkers()
  
  # loop through r_seq and N_seq -------------
  for (ri in 1:length(r_seq)){
    r = r_seq[ri]
    print(r)
    
    # define coefficients for multiple linear regression -----------
    # these coefficients will be used to generate mean_deflection using rnorm()
    beta0 = 1.34
    beta1 = -1.34*r
    beta2 = 9.26
    beta3 = 10.6*(1-r) - beta0 - beta1 - beta2
    
    for (Nj in 1:length(N_seq)){
      N = N_seq[Nj]
      print(N)
      
      # empty vector to store simlulated results 
      sim_random_result = NULL
      sim_target_result = NULL
      
      # empty vector to store number of random and targeted tissue for each simulation
      sim_random_number = NULL
      sim_target_number = NULL
      
      # number of simulations
      sims = 10000
      for (i in 1:sims){
        
        # balanced amount of new and standard needle
        num_patient = 1 # total number of patients
        cum_new_needle = 0 # cumulative number of new needles
        cum_std_needle = 0 # cumulative number of standard needles
        tracking = 0 # track new needles
        tdata = NULL
        while (tracking <= N){ # restrict number of new needles be smaller than upper limit (N)
          
          num_of_lesion = sample(c(1,2,3),1) # randomize lesion
          num_of_target = num_of_lesion*4
          num_of_random = 12
          total_needle_per_patient = num_of_target + num_of_random
          tracking = tracking + total_needle_per_patient/2
          # cum_std_needle = cum_std_needle + total_needle_per_patient/2
          
          if(tracking > N){ # if number of new needles exceed upper limit (N), break loop
            break
          }
       
          
          # standard needle target data ---------
          for (i in 1:(num_of_target/2)){
            #deflect_target_std = sample(std_data, 1)
            
            # count total stadard needle
            cum_std_needle = cum_std_needle + 1
            needle_type = 0
            tissue_type = 1
            # generate standard needle target data and bind to tdata
            tdata = bind_rows(tdata, 
                              bind_cols(
                                num_patient=num_patient, 
                                needle_type = 0,
                                mean_deflect = rnorm(n = 1, mean = beta0 + beta1*needle_type + beta2*tissue_type + 
                                                       beta3*needle_type*tissue_type, sd = 1.22),
                                tissue_type = 1,
                                num_of_lesion=num_of_lesion, 
                                num_of_target = num_of_target,
                                num_of_random = 12,
                                total_needle_per_patient= total_needle_per_patient, 
                                cum_new_needle = cum_new_needle, 
                                cum_std_needle = cum_std_needle
                              ))
            
            
          }
          
          # new needle target data -----------
          for (i in 1:(num_of_target/2)){
            #deflect_target_new = sample(new_data, 1)
            
            # count total new needle
            cum_new_needle = cum_new_needle + 1
            needle_type = 1
            tissue_type = 1
            # generate new needle target data and bind to tdata
            tdata = bind_rows(tdata, 
                              bind_cols(
                                num_patient=num_patient, 
                                needle_type = 1,
                                mean_deflect = rnorm(n = 1, mean = beta0 + beta1*needle_type + beta2*tissue_type + 
                                                       beta3*needle_type*tissue_type, sd = 1.52),
                                tissue_type = 1,
                                num_of_lesion=num_of_lesion, 
                                num_of_target = num_of_target,
                                num_of_random = 12,
                                total_needle_per_patient= total_needle_per_patient, 
                                cum_new_needle = cum_new_needle, 
                                cum_std_needle = cum_std_needle
                              ))
            
            
          }
          
          # standard needle random data -----------
          for (i in 1:(12/2)){
            #deflect_random_std = sample(std_data, 1)
            
            # count total stadard needle 
            cum_std_needle = cum_std_needle + 1
            needle_type = 0
            tissue_type = 0
            # generate standard needle random data and bind to tdata
            tdata = bind_rows(tdata, 
                              bind_cols(
                                num_patient=num_patient, 
                                needle_type = 0,
                                mean_deflect = rnorm(n = 1, mean = beta0 + beta1*needle_type + beta2*tissue_type + 
                                                       beta3*needle_type*tissue_type, sd = 1.22),
                                tissue_type = 0,
                                num_of_lesion=num_of_lesion, 
                                num_of_target = num_of_target,
                                num_of_random = 12,
                                total_needle_per_patient= total_needle_per_patient, 
                                cum_new_needle = cum_new_needle, 
                                cum_std_needle = cum_std_needle
                              ))
            
            
          }
          
          # new needle random data -------------
          for (i in 1:(12/2)){
            #deflect_random_new = sample(new_data, 1)
            
            # count total new needle
            cum_new_needle = cum_new_needle + 1
            needle_type = 1
            tissue_type = 0
            # generate new needle random data and bind to tdata
            tdata = bind_rows(tdata, 
                              bind_cols(
                                num_patient=num_patient, 
                                needle_type = 1,
                                mean_deflect = rnorm(n = 1, mean = beta0 + beta1*needle_type + beta2*tissue_type + 
                                                       beta3*needle_type*tissue_type, sd = 1.52),
                                tissue_type = 0,
                                num_of_lesion=num_of_lesion, 
                                num_of_target = num_of_target,
                                num_of_random = 12,
                                total_needle_per_patient= total_needle_per_patient, 
                                cum_new_needle = cum_new_needle, 
                                cum_std_needle = cum_std_needle
                              ))
            
            
          }
          
          
          num_patient = num_patient + 1
          
        }
        
        # count number of needles ------------
        random_needle = dim(tdata[tdata$needle_type == 1 & tdata$tissue_type == 0,])[1]
        target_needle = dim(tdata[tdata$needle_type == 1 & tdata$tissue_type == 1,])[1]
        
        
        # fit gee model -----------
        full = geeglm(mean_deflect ~ needle_type + tissue_type + needle_type*tissue_type, id = needle_type, 
                      corstr = "exchangeable", data = tdata)
        
        # extract coefficient, standard deviation, variance -----------
        coef = coef(full)
        se = sqrt(diag(full$geese$vbeta))
        var = diag(full$geese$vbeta)
        cov_var = full$geese$vbeta
        df = full$df.residual
        # wald test: test mean deflection between new and standard needle in random tissue
        # t = (beta1_H1 - beta_H0)/se(beta1_H1)
        t_beta1 = (coef[2]-(beta1_H0))/se[2]
        p_beta1 = 2*pt(-abs(as.numeric(t_beta1)), df = df)
        
        # wald test: test mean deflection between new and standard needle in target tissue -------
        # se_pool = sqrt(var(beta1) + var(beta3) - 2cov(beta1)(beta3))
        se_pool = sqrt(var[2] + var[4] - 2*cov_var[2, 4])
        t_beta1_3 = (coef[2] + coef[4] - beta1_3_H0)/se_pool
        p_beta1_3 = 2*pt(-abs(as.numeric(t_beta1_3)), df = df)
        
        # store result to vector ---------
        sim_random_result = c(sim_random_result, p_beta1)
        sim_target_result = c(sim_target_result, p_beta1_3)
        
        # store number of random and target tissue
        sim_random_number = c(sim_random_number, random_needle)
        sim_target_number = c(sim_target_number, target_needle)
      }
      
      # test power -----------
      random_reject = sum(sim_random_result < 0.05)
      target_reject = sum(sim_target_result < 0.05)
      print(random_reject)
      print(target_reject)
      
      # take average of random and targeted tissues for each N and r
      avg_random = mean(sim_random_number)
      avg_target = mean(sim_target_number)
      
      # store power result to matrix ------------
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



df_random = data.frame(N = rep(c(0, 50, seq(100, 600, 100)),7),
                       r = c(rep(0.40, 8), rep(0.45, 8), rep(0.50, 8), rep(0.55, 8), rep(0.60, 8), 
                             rep(0.65, 8), rep(0.70, 8)),
                       reject = as.numeric(c(0, reject_random_matrix1[,1], 0, reject_random_matrix1[,2], 0, reject_random_matrix1[,3],
                                             0, reject_random_matrix1[,4], 0, reject_random_matrix1[,5], 0, reject_random_matrix1[,6],
                                             0, reject_random_matrix1[,7])))
df_random$reject = (df_random$reject/10000)*100

#df_random = read.csv(file = "./project4/gee/random_gee_sim5000.csv")
df_random$N = rep(c(0, 28, 58, 118, 178, 238, 298, 358), 7)

# plot random -------------
ggplot(data = df_random, aes(x=N, y=reject)) +
  geom_smooth(aes(group=factor(r), color = factor(r)), se = FALSE) +
  geom_hline(yintercept = 80, linetype = "dashed") +
  geom_vline(xintercept = 298, linetype = "dashed") +
  scale_y_continuous(name = "Pr(reject)", limits = c(0,100), breaks = seq(0, 100, 20)) +
  scale_x_continuous(name = "Average number of new needles in random biopsies across simulations",
                     limits = c(0, 358), breaks = c(0, 28, 58, 118, 178, 238, 298, 358)) +
  labs(color = "Reduction") +
  ggtitle("Random tissue: gee (wald test: test beta1)")

# power against reduction
# ggplot(data = df_random %>% filter(N != 0), aes(x=r, y=reject)) + 
#   geom_smooth(aes(group=factor(N), color = factor(N)), se = FALSE) +
#   geom_hline(yintercept = 80, linetype = "dashed") + 
#   scale_y_continuous(name = "Pr(reject)", limits = c(0,100), breaks = seq(0, 100, 20)) +
#   scale_x_continuous(name = "reduction in deflection",limits = c(0.4, 0.7), breaks = seq(0.4, 0.7, 0.05)) +
#   labs(color = "N per arm") +
#   ggtitle("Random tissue: GEE (wald test: test beta1)")


# target tissue result ----------
reject_target_matrix1 = apply(reject_target_matrix, 2,as.numeric)
number_target_mean = apply(number_target_matrix, 1, mean)
number_target_sd = apply(number_target_matrix, 1, sd)


df_target = data.frame(N = rep(c(0, 50, seq(100, 600, 100)),7),
                       r = c(rep(0.40, 8), rep(0.45, 8), rep(0.50, 8), rep(0.55, 8), rep(0.60, 8), 
                             rep(0.65, 8), rep(0.70, 8)),
                       reject = as.numeric(c(0, reject_target_matrix1[,1], 0, reject_target_matrix1[,2], 0, reject_target_matrix1[,3],
                                             0, reject_target_matrix1[,4], 0, reject_target_matrix1[,5], 0, reject_target_matrix1[,6],
                                             0, reject_target_matrix1[,7])))
df_target$reject = (df_target$reject/10000)*100

#df_target = read.csv(file = "./project4/gee/target_gee_sim5000.csv")
df_target$N = rep(c(0, 18, 38, 78, 118, 158, 198, 238), 7)

# plot target ----------
ggplot(data = df_target, aes(x=N, y=reject)) +
  geom_smooth(aes(group=factor(r), color = factor(r)), se = FALSE) +
  geom_hline(yintercept = 80, linetype = "dashed") +
  geom_vline(xintercept = 198, linetype = "dashed") +
  scale_y_continuous(name = "Pr(reject)", limits = c(0,100), breaks = seq(0, 100, 20)) +
  scale_x_continuous(name = "Average number of new needles in targeted biopsies across simulations", 
                     limits = c(0, 238), breaks = c(0, 18, 38, 78, 118, 158, 198, 238)) +
  labs(color = "reduction") +
  ggtitle("Target tissue GEE (wald test: test beta1 + beta3)")

# ggplot(data = df_target %>% filter(N != 0), aes(x=r, y=reject)) + 
#   geom_smooth(aes(group=factor(N), color = factor(N)), se = FALSE) +
#   geom_hline(yintercept = 80, linetype = "dashed") + 
#   scale_y_continuous(name = "Pr(reject)", limits = c(0,100), breaks = seq(0, 100, 20)) +
#   scale_x_continuous(name = "reduction in deflection",limits = c(0.4, 0.7), breaks = seq(0.4, 0.7, 0.05)) +
#   labs(color = "N per arm") +
#   ggtitle("Target tissue: GEE (wald test: test beta1 + beta3)")

write.csv(as.data.frame(df_random), "~/Desktop/WINTER2020/BIOS699/project4/random_gee_sim10000.csv", row.names = F)
write.csv(as.data.frame(df_target), "~/Desktop/WINTER2020/BIOS699/project4/target_gee_sim10000.csv", row.names = F)



