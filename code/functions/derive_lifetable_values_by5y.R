#### lx

derive_lx_values <- function(nmx, ages){
        a0 <- 0.07 + 1.7*nmx[1] 
        a1 <- 1.5
        a_inf <- 1/nmx[length(nmx)]
        nax <- c(a0, a1, ((ages - lag(ages))/2)[4:(length(ages))], a_inf) 
        ns <- c(1,4, (ages - lag(ages))[4:(length(ages))], Inf) #interval length
        nqx <- (ns*nmx) / (1 + (ns - nax)*nmx)
        nqx[length(nqx)] <- 1 #last age prob dying =1
        l0 <- 1
        lx <- c(l0, rep(0, length(nqx)-1))
        for (i in 2:length(nqx)){
                lx[i]<- lx[i-1]*(1-nqx[i-1])
        }
        
        return(lx)
}


###### Lx

#### convert nmx and lx to nLx #####
#### using process in EDM (Wachter 2014) ###

derive_nLx_values <- function (nmx, ages){
        
        lx <- derive_lx_values(nmx, ages)
        a0 <- 0.07 + 1.7*nmx[1] 
        a1 <- 1.5
        a_inf <- 1/nmx[length(nmx)]
        nax <- c(a0, a1, ((ages - lag(ages))/2)[4:(length(ages))], a_inf) 
        ns <- c(1,4, (ages - lag(ages))[4:(length(ages))], Inf) #interval length
        
        # 
        ndx <- rep(NA, length(lx))
        for(i in 1:(length(ndx)-1)){
                ndx[i] <- lx[i] - lx[i+1]
        }
        ndx[length(ndx)] <- lx[length(ndx)]
        
        nLx <- rep(NA, length(nmx))
        for(i in 1:(length(nLx)-1)){
                nLx[i] <- ns[i]*lx[i+1] + nax[i]*ndx[i]
        }
        
        nLx[length(nLx)] <-  nax[length(nax)]*ndx[length(ndx)]
        
        return(nLx)
}


######## ex

# added arg full so that
# previous code shouldn't be
# impacted.
derive_ex_values <- function(nmx, ages, full=FALSE){
        lx <- derive_lx_values(nmx, ages)
        nLx <- derive_nLx_values(nmx, ages)
        nTx <- rev(cumsum(rev(nLx)))
        
        if (full==FALSE) {
                ex <- rev(cumsum(rev(nLx)))/lx
        } else {
                eX <- rev(cumsum(rev(nLx)))/lx
                ex <- tibble(lx = lx,
                             qx = 1-(lead(lx, default = 0)/lx),
                             nLx = nLx,
                             nTx = nTx,
                             ex = eX)
        } 
        
        return(ex)
}


# derive e0 from qx 
# useful for chiang CI
derive_ex_values_qx <- function(nmx, qx, ages){
        a0 <- 0.07 + 1.7*nmx[1] 
        a1 <- 1.5
        a_inf <- 1/nmx[length(nmx)]
        nax <- c(a0, a1, ((ages - lag(ages))/2)[4:(length(ages))], a_inf) 
        ns <- c(1,4, (ages - lag(ages))[4:(length(ages))], Inf) #interval length
        # required for chiang interval as 
        # qx can be NaN
        qx[is.na(qx)] = 0
        px = 1-qx
        lx = c(1, cumprod(head(px, -1)))
        
        ndx <- rep(NA, length(lx))
        for(i in 1:(length(ndx)-1)){
                ndx[i] <- lx[i] - lx[i+1]
        }
        ndx[length(ndx)] <- lx[length(ndx)]
        
        nLx <- rep(NA, length(nmx))
        for(i in 1:(length(nLx)-1)){
                nLx[i] <- ns[i]*lx[i+1] + nax[i]*ndx[i]
        }
        
        nLx[length(nLx)] <-  nax[length(nax)]*ndx[length(ndx)]
        nTx <- rev(cumsum(rev(nLx)))
        ex <- nTx/lx
        
        return(ex)
}
