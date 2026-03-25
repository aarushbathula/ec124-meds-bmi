# Shared project utilities for reproducible local execution.

project_root <- function() {
  candidates <- unique(c(
    getwd(),
    file.path(getwd(), "..")
  ))

  for (candidate in candidates) {
    root <- normalizePath(candidate, winslash = "/", mustWork = FALSE)
    if (
      file.exists(file.path(root, "code")) &&
      file.exists(file.path(root, "README.md"))
    ) {
      return(root)
    }
  }

  stop(
    "Could not locate the project root. Run the script from the repository root ",
    "or from the code directory.",
    call. = FALSE
  )
}

load_required_packages <- function(packages) {
  missing <- packages[!(packages %in% installed.packages()[, "Package"])]

  if (length(missing) > 0) {
    stop(
      "Missing required packages: ",
      paste(missing, collapse = ", "),
      ". Install them before running the pipeline.",
      call. = FALSE
    )
  }

  invisible(lapply(packages, library, character.only = TRUE))
}

ensure_project_dirs <- function(root_dir) {
  dirs <- c(
    file.path(root_dir, "data"),
    file.path(root_dir, "output"),
    file.path(root_dir, "output", "figures"),
    file.path(root_dir, "output", "tables"),
    file.path(root_dir, "output", "logs")
  )

  invisible(lapply(dirs, dir.create, recursive = TRUE, showWarnings = FALSE))
}
