# =========================
# Compare Two EddyPro Fluxnet CSV Files
# FINAL VERSION
# =========================

# =========================
# 1. Set file paths
# 修改这里即可
# =========================

old_file <- "~/Documents/Final/eddypro_muka_head01_fluxnet_2018_aligned_FINAL.csv"

new_file <- "~/Documents/eddypro_muka_head01_fluxnet_2018_FINAL.csv"

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

# =========================
# 4. Column difference check
# =========================

cat("\n====================\n")
cat("Column Difference Check\n")
cat("====================\n\n")

cat("Columns in old file but not in new file:\n")
print(
  setdiff(
    names(old),
    names(new)
  )
)

cat("\nColumns in new file but not in old file:\n")
print(
  setdiff(
    names(new),
    names(old)
  )
)

# =========================
# 5. TIMESTAMP_START check
# =========================

cat("\n====================\n")
cat("TIMESTAMP_START Check\n")
cat("====================\n\n")

if(!"TIMESTAMP_START" %in% names(old)) {
  stop("Old file does not contain TIMESTAMP_START.")
}

if(!"TIMESTAMP_START" %in% names(new)) {
  stop("New file does not contain TIMESTAMP_START.")
}

cat("Duplicated TIMESTAMP_START in old file:\n")
print(
  sum(
    duplicated(old$TIMESTAMP_START)
  )
)

cat("\nDuplicated TIMESTAMP_START in new file:\n")
print(
  sum(
    duplicated(new$TIMESTAMP_START)
  )
)

# =========================
# 6. Timestamp coverage check
# =========================

cat("\n====================\n")
cat("Timestamp Coverage Check\n")
cat("====================\n\n")

cat("TIMESTAMP_START in old file but not in new file:\n")
print(
  length(
    setdiff(
      old$TIMESTAMP_START,
      new$TIMESTAMP_START
    )
  )
)

cat("\nTIMESTAMP_START in new file but not in old file:\n")
print(
  length(
    setdiff(
      new$TIMESTAMP_START,
      old$TIMESTAMP_START
    )
  )
)

# =========================
# 7. Monthly coverage check
# =========================

cat("\n====================\n")
cat("Monthly Coverage Check - Old File\n")
cat("====================\n\n")

print(
  table(
    substr(
      old$TIMESTAMP_START,
      1,
      6
    )
  )
)

cat("\n====================\n")
cat("Monthly Coverage Check - New File\n")
cat("====================\n\n")

print(
  table(
    substr(
      new$TIMESTAMP_START,
      1,
      6
    )
  )
)

# =========================
# 8. Final summary
# =========================

cat("\n====================\n")
cat("Final Summary\n")
cat("====================\n\n")

if(
  nrow(old) == nrow(new) &&
  length(setdiff(old$TIMESTAMP_START, new$TIMESTAMP_START)) == 0 &&
  length(setdiff(new$TIMESTAMP_START, old$TIMESTAMP_START)) == 0
) {
  cat("Result: The two files have the same timestamp coverage.\n")
} else {
  cat("Result: The two files have different timestamp coverage. Further inspection is needed.\n")
}

cat("\nColumn count difference:\n")
cat(ncol(old) - ncol(new), "\n")
