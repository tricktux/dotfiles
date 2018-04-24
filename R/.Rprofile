# The .First function is called after everything else in .Rprofile is executed
.First <- function() {
# Print a welcome message
	message("Welcome back ", Sys.getenv("USER"),"!\n","working directory is:", getwd())
}

# Always load the 'methods' package
library(methods)

# Load the devtools and colorout packages if in interactive mode
if (interactive()) {
	library(devtools)
	library(colorout)
}

options(prompt = paste(paste(Sys.info()[c("user", "nodename")], collapse = "@"),"[R] "))            # customize your R prompt with username and hostname in this format: user@hostname [R]
options(digits = 12)                                                                                # number of digits to print. Default is 7, max is 15
options(stringsAsFactors = FALSE)                                                                   # Disable default conversion of character strings to factors
options(show.signif.stars = FALSE)                                                                  # Don't show stars indicating statistical significance in model outputs
error <- quote(dump.frames("${R_HOME_USER}/testdump", TRUE))                                        # post-mortem debugging facilities

## Default repo USA->TX
local({r <- getOption("repos")
	r["CRAN"] <- "https://cloud.r-project.org/" 
	options(repos=r)
})
