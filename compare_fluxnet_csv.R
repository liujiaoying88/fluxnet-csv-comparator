# =========================
# Compare Two EddyPro Fluxnet CSV Files
# STRICT VALIDATION VERSION
# =========================

# =========================
# 1. Set file paths
# 修改这里即可
# =========================

old_file <- "~/Documents/Final/eddypro_muka_head01_fluxnet_2016_aligned.csv"

new_file <- "~/Documents/eddypro_muka_head01_fluxnet_2016_FINAL.csv"

# =========================
# 2. Read CSV files
# =========================

old <- read.csv(
  old_file,
  stringsAsFactors = FALSE,
  check.names = FALSE
)

new <- read.csv(
  new_file,
  stringsAsFactors = FALSE,
  check.names = FALSE
)

# =========================
# 3. Basic structure check
# =========================

cat("\n====================\n")
cat("Basic Structure Check\n")
cat("====================\n\n")

cat("Old file rows:", nrow(old), "\n")
cat("New file rows:", nrow(new), "\n\n")

cat("Old file columns:", ncol(old), "\n")
cat("New file columns:", ncol(new), "\n\n")

cat("Row count difference old - new:", nrow(old) - nrow(new), "\n")
cat("Column count difference old - new:", ncol(old) - ncol(new), "\n")

# =========================
# 4. Column difference check
# =========================

cat("\n====================\n")
cat("Column Difference Check\n")
cat("====================\n\n")

cat("Columns in old file but not in new file:\n")
print(setdiff(names(old), names(new)))

cat("\nColumns in new file but not in old file:\n")
print(setdiff(names(new), names(old)))

# =========================
# 5. TIMESTAMP_START existence check
# =========================

cat("\n====================\n")
cat("TIMESTAMP_START Existence Check\n")
cat("====================\n\n")

if(!"TIMESTAMP_START" %in% names(old)) {
  stop("Old file does not contain TIMESTAMP_START.")
}

if(!"TIMESTAMP_START" %in% names(new)) {
  stop("New file does not contain TIMESTAMP_START.")
}

cat("Both files contain TIMESTAMP_START.\n")

# =========================
# 6. TIMESTAMP_START format check
# =========================

cat("\n====================\n")
cat("TIMESTAMP_START Format Check\n")
cat("====================\n\n")

old$TIMESTAMP_START <- trimws(as.character(old$TIMESTAMP_START))
new$TIMESTAMP_START <- trimws(as.character(new$TIMESTAMP_START))

old_bad_timestamp <- sum(!grepl("^[0-9]{12}$", old$TIMESTAMP_START))
new_bad_timestamp <- sum(!grepl("^[0-9]{12}$", new$TIMESTAMP_START))

cat("Invalid TIMESTAMP_START in old file:", old_bad_timestamp, "\n")
cat("Invalid TIMESTAMP_START in new file:", new_bad_timestamp, "\n")

# =========================
# 7. Duplicated timestamp check
# =========================

cat("\n====================\n")
cat("Duplicated TIMESTAMP_START Check\n")
cat("====================\n\n")

cat("Duplicated TIMESTAMP_START in old file:", sum(duplicated(old$TIMESTAMP_START)), "\n")
cat("Duplicated TIMESTAMP_START in new file:", sum(duplicated(new$TIMESTAMP_START)), "\n")

# =========================
# 8. Timestamp coverage check
# =========================

cat("\n====================\n")
cat("Timestamp Coverage Check\n")
cat("====================\n\n")

old_not_in_new <- setdiff(old$TIMESTAMP_START, new$TIMESTAMP_START)
new_not_in_old <- setdiff(new$TIMESTAMP_START, old$TIMESTAMP_START)

cat("TIMESTAMP_START in old file but not in new file:", length(old_not_in_new), "\n")
cat("TIMESTAMP_START in new file but not in old file:", length(new_not_in_old), "\n")

if(length(old_not_in_new) > 0) {
  cat("\nExamples from old not in new:\n")
  print(head(old_not_in_new, 10))
}

if(length(new_not_in_old) > 0) {
  cat("\nExamples from new not in old:\n")
  print(head(new_not_in_old, 10))
}

# =========================
# 9. Monthly coverage check
# =========================

cat("\n====================\n")
cat("Monthly Coverage Check - Old File\n")
cat("====================\n\n")

print(table(substr(old$TIMESTAMP_START, 1, 6)))

cat("\n====================\n")
cat("Monthly Coverage Check - New File\n")
cat("====================\n\n")

print(table(substr(new$TIMESTAMP_START, 1, 6)))

# =========================
# 10. Timestamp-like value leakage check
# 检查是否有时间戳跑到其他列
# =========================

cat("\n====================\n")
cat("Timestamp-like Value Leakage Check - Old File\n")
cat("====================\n\n")

old_timestamp_like_count <- sapply(
  old,
  function(x) {
    sum(grepl("^[0-9]{12}$", as.character(x)))
  }
)

print(
  sort(
    old_timestamp_like_count,
    decreasing = TRUE
  )[1:min(10, length(old_timestamp_like_count))]
)

cat("\n====================\n")
cat("Timestamp-like Value Leakage Check - New File\n")
cat("====================\n\n")

new_timestamp_like_count <- sapply(
  new,
  function(x) {
    sum(grepl("^[0-9]{12}$", as.character(x)))
  }
)

print(
  sort(
    new_timestamp_like_count,
    decreasing = TRUE
  )[1:min(10, length(new_timestamp_like_count))]
)

# =========================
# 11. Preview first and last rows
# =========================

cat("\n====================\n")
cat("Preview New File - First 10 Rows, First 10 Columns\n")
cat("====================\n\n")

print(head(new[, 1:min(10, ncol(new))], 10))

cat("\n====================\n")
cat("Preview New File - Last 10 Rows, First 10 Columns\n")
cat("====================\n\n")

print(tail(new[, 1:min(10, ncol(new))], 10))

# =========================
# 12. Final summary
# =========================

cat("\n====================\n")
cat("Final Summary\n")
cat("====================\n\n")

same_timestamp_coverage <- (
  length(old_not_in_new) == 0 &&
    length(new_not_in_old) == 0
)

new_timestamp_clean <- (
  new_bad_timestamp == 0 &&
    sum(duplicated(new$TIMESTAMP_START)) == 0
)

cat("Same timestamp coverage:", same_timestamp_coverage, "\n")
cat("New file timestamp clean:", new_timestamp_clean, "\n")
cat("Row count difference old - new:", nrow(old) - nrow(new), "\n")
cat("Column count difference old - new:", ncol(old) - ncol(new), "\n\n")

if(same_timestamp_coverage && new_timestamp_clean) {
  cat("Result: The new file is structurally valid based on timestamp coverage and timestamp cleanliness.\n")
} else {
  cat("Result: Further inspection is needed. Timestamp coverage or timestamp cleanliness is not fully valid.\n")
}
