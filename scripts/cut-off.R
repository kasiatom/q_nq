require(dplyr)
require(readr)
require(ggplot2)

merged_data <- read_delim("HMMRATAC_output/merged-data.tsv",
													delim = "\t", escape_double = FALSE,
													col_names = FALSE, trim_ws = TRUE)


colnames(merged_data) <- c("score", "peak_number", "total_length", "average_length" )

merged_data <- merged_data %>%
	mutate("normal_length" = average_length < 1000 & average_length > 420)

 merged_data %>% 
 	filter(normal_length) %>%
 	summarize("min" = min(score), "max" = max(score), "mean" = mean(score), "median" = median(score))

plot1 <- merged_data %>%
	ggplot(aes(x=score, y=peak_number, color = normal_length)) +
	geom_point() + 
	theme_bw()

ggsave("plot1.png")

plot2 <- merged_data %>%
	ggplot(aes(x=score, y=average_length, color = normal_length)) +
	geom_point() + 
	theme_bw()

ggsave("plot2.png")

plot3 <- merged_data %>%
	filter(normal_length) %>%
	ggplot(aes(x=score, color = normal_length)) +
	geom_density() + 
	theme_bw()

ggsave("plot3.png")
