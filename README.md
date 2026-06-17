# notes 2026-01

The coefficients for the wetday-precip relationship were developed based on the wetfrac30m_t0.2_202512.nc file,
i.e., wetdays threshholded to a 0.2mm/day minimum to count as a wet day.

The coefficients are calculated in R using `lmfit <- lm(dep ~ log(ind))` where dep is observed wet day fraction and
ind ind is total monthly precip. 

