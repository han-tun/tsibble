by_row <- function(FUN, .data, ordered = TRUE, interval = NULL, ...) {
  FUN <- match.fun(FUN, descend = FALSE)
  tbl <- FUN(as_tibble(.data), ...)
  update_tsibble(tbl, .data, ordered = ordered, interval = interval)
}

# put new data with existing attributes
update_tsibble <- function(new, old, ordered = TRUE, interval = NULL) {
  restore_index_class(build_tsibble_meta(
    new, key = key(old), index = !! index(old), index2 = !! index2(old),
    groups = groups(old), regular = is_regular(old),
    ordered = ordered, interval = interval
  ), old)
}

# needed when grouping by index2 (e.g. summarise)
as_tibble2 <- function(x) {
  grps <- groups(x)
  idx2 <- index2(x)
  x <- as_tibble(x)
  group_by(x, !!! flatten(c(grps, idx2)))
}

as_grouped_df <- function(x) {
  class(x) <- class(x)[-match("tbl_ts", class(x))] # remove "tbl_ts"
  class(x)[match("grouped_ts", class(x))] <- "grouped_df"
  x
}

restore_index_class <- function(new, old) {
  old_idx <- as_string(index(old))
  new_idx <- as_string(index(new))
  class(new[[new_idx]]) <- class(old[[old_idx]])
  if (!identical(interval(new), interval(old))) {
    attr(new, "interval") <- pull_interval(new[[new_idx]])
  }
  new
}

join_tsibble <- function(FUN, x, y, by = NULL, copy = FALSE, ...) {
  FUN <- match.fun(FUN, descend = FALSE)
  tbl_x <- as_tibble(x)
  tbl_y <- as_tibble(y)
  tbl <- FUN(x = tbl_x, y = tbl_y, by = by, copy = copy, ...)
  update_tsibble(tbl, x, ordered = is_ordered(x))
}

tsibble_rename <- function(.data, ...) {
  names_dat <- names(.data)
  val_vars <- tidyselect::vars_rename(names_dat, ...)

  # index
  idx <- index_rename(.data, val_vars)
  # index2
  idx2 <- index2_rename(.data, val_vars)
  attr(.data, "index2") <- idx2
  # key (key of the same size (bf & af))
  new_key <- key_rename(.data, val_vars)
  # groups
  new_grp <- grp_rename(.data, val_vars)

  names(.data) <- names(val_vars)
  build_tsibble_meta(
    .data, key = new_key, index = !! idx, index2 = !! idx2,
    groups = new_grp, regular = is_regular(.data),
    ordered = is_ordered(.data), interval = interval(.data)
  )
}

tsibble_select <- function(.data, ..., validate = TRUE) {
  dots <- c(enexprs(...), index(.data))
  names_dat <- names(.data)
  val_vars <- tidyselect::vars_select(names_dat, !!! dots)
  sel_data <- select(as_tibble(.data), !!! val_vars)
  
  # index
  idx <- index_rename(.data, val_vars)
  # index2
  idx2 <- index2_rename(.data, val_vars)
  # key (key of the reduced size (bf & af) but also different names)
  key_vars <- val_vars[val_vars %in% key_vars(.data)]
  tmp_data <- key_remove(.data, key_vars, validate = FALSE)
  new_key <- key_rename(tmp_data, key_vars)
  # groups
  new_grp <- grp_rename(.data, val_vars)
  
  if (validate) {
    vec_names <- union(names(val_vars), names(.data))
    # either key or index is present in ...
    # suggests that the operations are done on these variables
    # validate = TRUE to check if tsibble still holds
    # val_idx <- has_index(vec_names, .data)
    # val_key <- has_any_key(vec_names, .data)
    # validate <- val_idx || val_key
    validate <- has_any_key(vec_names, .data)
  }
  
  build_tsibble(
    sel_data, key = new_key, index = !! idx, index2 = !! idx2,
    groups = new_grp, regular = is_regular(.data), validate = validate, 
    ordered = is_ordered(.data), interval = interval(.data)
  )
}