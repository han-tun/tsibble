context("Sliding window function and its variants")

x <- 1:5
y <- 6:10
z <- 11:15
lst <- list(x = x, y = y, z = z)
df <- as.data.frame(lst)
lst_cols <- tibble::tibble(lst = list(df, df, df))

test_that("Invalid input", {
  expect_error(slider(lst, 0), "must not be 0.")
  expect_error(slider(lst, c(1, 3)), "must be an integer.")
  expect_error(slider(x, -6), "larger")
  expect_error(slider(list()), "larger")
  expect_error(slider(x, .bind = TRUE), "only accepts list")
})

test_that("check .align", {
  expect_error(slide(x, ~., .size = 2, .align = "center"), "even")
  expect_equal(
    slide(x, ~., .size = 4, .align = "center-right")[1:2],
    list(NA, NA)
  )
  expect_equal(
    slide(x, ~., .size = 3, .align = "center", .fill = NULL),
    list(1:3, 2:4, 3:5)
  )
})

test_that("slider() & pslider()", {
  expect_equal(slider(x, .size = 2), list(1:2, 2:3, 3:4, 4:5))
  expect_equal(slider(x, .size = -2), list(5:4, 4:3, 3:2, 2:1))
  expect_equal(
    partial_slider(x, .size = 2),
    list(c(NA, 1), 1:2, 2:3, 3:4, 4:5)
  )
  expect_equal(
    partial_slider(x, .size = 2, .step = 2),
    list(c(NA, 1), 2:3, 4:5)
  )
  expect_equal(
    partial_slider(x, .size = -2, .align = "left"),
    list(c(NA, 5), 5:4, 4:3, 3:2, 2:1)
  )
  expect_equal(
    partial_slider(x, .size = -2, .step = 2, .align = "left"),
    list(c(NA, 5), 4:3, 2:1)
  )
  expect_equal(
    partial_slider(x, .size = -2, .align = "right"),
    list(5:4, 4:3, 3:2, 2:1, c(1, NA))
  )
  expect_equal(
    slider(lst, .size = 2),
    list(list(x = x, y = y), list(y = y, z = z))
  )
  expect_equal(
    slider(df, .size = 2),
    slider(lst, .size = 2)
  )
  expect_equal(
    pslider(lst, .size = 2),
    list(list(list(x = x, y = y), list(y = y, z = z)))
  )
  expect_equal(
    pslider(list(x, y), list(y), .size = 2),
    list(list(list(x, y)), list(list(y, y)))
  )
  expect_equal(
    pslider(df, .size = 2),
    pslider(lst, .size = 2)
  )
  expect_equal(
    pslider(df, df, .size = 2),
    pslider(lst, lst, .size = 2)
  )
  expect_equal(
    pslider(x, 1), # recycling
    list(as.list(1:5), as.list(rep(1, 5)))
  )
  expect_equal(
    slider(lst_cols$lst, .size = 2, .bind = TRUE)[[1]],
    bind_rows(df, df)
  )
  expect_equal(
    unname(partial_slider(lst, .size = 2, .bind = TRUE, .fill = NA_integer_)[[1]]),
    c(NA, 1:5)
  )
  expect_equal(
    slider(list(x = 1.5, y = 1L), .size = 2, .bind = TRUE),
    list(c(1.5, 1.0))
  )
})

test_that("Argument `.align`", {
  expect_equal(
    slide_int(x, sum, .size = 3, .align = "left"),
    c(6L, 9L, 12L, NA_integer_, NA_integer_)
  )
  expect_equal(
    slide_int(x, sum, .size = 3, .align = "center"),
    c(NA_integer_, 6L, 9L, 12L, NA_integer_)
  )
})

test_that("slide() and its variants", {
  expect_equal(
    slide_dbl(x, mean, .size = 2),
    c(NA, purrr::map_dbl(slider(x, 2), mean))
  )
  expect_equal(
    slide_dbl(x, mean, .size = 2),
    rev(slide_dbl(x, mean, .size = -2))
  )
  expect_equal(
    slide_dbl(x, mean, .size = 2, .step = 2),
    c(NA, 1.5, NA, 3.5, NA)
  )
  expect_equal(
    slide(lst, ~., .size = 2, .partial = TRUE),
    list(list(NA, x = x), list(x = x, y = y), list(y = y, z = z))
  )
  expect_equal(
    slide(lst, ~., .size = 2),
    list(NA, list(x = x, y = y), list(y = y, z = z))
  )
  expect_equal(
    slide_dfr(x, ~ data.frame(x = .), .size = 1),
    data.frame(x = x)
  )
  expect_equal(
    slide_dfc(x, ~ data.frame(x = .), .size = 1),
    data.frame(x = 1, x1 = 2, x2 = 3, x3 = 4, x4 = 5)
  )
  expect_equal(
    slide_int(lst_cols$lst, ~ sum(.$x), .size = 2, .bind = TRUE),
    c(NA, 30L, 30L)
  )
})

test_that("slide2() and its variants", {
  expect_equal(
    slide2_int(x, y, sum, .size = 2, .fill = NA_integer_),
    c(NA_integer_, seq.int(16, by = 4, length.out = 4))
  )
  expect_equal(
    slide2(x, y, sum, .size = 2, .fill = NA_integer_, .partial = TRUE),
    slide2(x, y, sum, .size = 2, .fill = NA_integer_)
  )
  expect_equal(
    slide2(lst, lst, ~ sum(unlist(.x), unlist(.y)), .size = 2, .fill = NA_real_),
    list(NA_real_, 110, 210)
  )
  expect_equal(
    slide2(df, df, ~., .size = 2),
    slide2(lst, lst, ~., .size = 2)
  )
  expect_equal(
    slide2_dfr(df, df, ~ tibble::tibble(x = sum(.x, .y)), .size = 2, .bind = TRUE)[2, 1, drop = TRUE],
    sum(df[, 1:2]) * 2
  )
  expect_equal(
    slide2_dfc(df, df, ~ tibble::tibble(x = sum(.x, .y)), .size = 2, .bind = TRUE)[1, 2, drop = TRUE],
    sum(df[, 1:2]) * 2
  )
})

test_that("pslide() and its variants", {
  expect_equal(
    pslide_lgl(lst, ~ sum(..1, ..2) > 10, size = 1),
    pslide_int(lst, ~ sum(..1, ..2), size = 1) > 10
  )
  expect_equal(
    pslide(lst, ~ sum(..1, ..2) > 10, size = 1),
    as.list(pslide_int(lst, ~ sum(..1, ..2), size = 1) > 10)
  )
  expect_equal(
    pslide(list(lst, lst), ~..1, .size = 2),
    list(NA, list(x = x, y = y), list(y = y, z = z))
  )
  expect_equal(
    pslide(list(list(x, y), list(y)), ~ list(..1, ..2)),
    pslide(list(list(x, y), list(y, y)), ~ list(..1, ..2))
  )
  my_sum <- function(...) {
    data <- list(...)
    sum(data$x)
  }
  expect_equal(
    pslide_int(df, my_sum, .size = 2),
    c(NA, 3, 5, 7, 9)
  )
  expect_equal(
    pslide(df, my_sum, .size = 2, .partial = TRUE),
    list(NA_real_, 3, 5, 7, 9)
  )
  my_sum2 <- function(...) {
    data <- list(...)
    data.frame(x = sum(data$x))
  }
  expect_equal(
    pslide_dfr(df, my_sum2, .size = 2),
    tibble(x = c(NA, 3L, 5L, 7L, 9L))
  )
  expect_equal(
    pslide_dfc(df, my_sum2, .size = 2),
    tibble(x = NA, x1 = 3L, x2 = 5L, x3 = 7L, x4 = 9L)
  )
})

x1 <- list(1:3, 1, 1:2)
x2 <- list(1:3, 1)
x3 <- list(1:3, 1:3)

test_that("recycle()", {
  expect_equal(recycle(integer(0)), integer(0))
  expect_error(recycle(x1), "Element 3 has length 2, not 1 or 3.")
  expect_equal(recycle(x2), list(1:3, rep(1, 3)))
  expect_equal(recycle(x3), x3)
})

test_that("pad_slide()", {
  expect_equal(
    pad_slide(c(4, 7), .size = 4, .step = 3, .align = "r", expect_length = 7)[1:4],
    c(rep(NA_real_, 3), 4)
  )
  expect_equal(
    length(pad_slide(c(4, 7), .size = 4, .step = 3, .align = "r", expect_length = 7)),
    7
  )
  expect_equal(
    pad_slide(c(1, 4), .size = 4, .step = 3, .align = "l", expect_length = 7)[4:7],
    c(4, rep(NA_real_, 3))
  )
  expect_equal(
    pad_slide(c(3, 6), .size = 6, .step = 3, .align = "cl", expect_length = 9)[1:3],
    c(rep(NA_real_, 2), 3)
  )
  expect_equal(
    pad_slide(c(4, 7), .size = 6, .step = 3, .align = "cr", expect_length = 9)[1:4],
    c(rep(NA_real_, 3), 4)
  )
  expect_equal(
    pad_slide(3:6, .size = 6, .align = "cl")[1:3],
    c(rep(NA_real_, 2), 3)
  )
  expect_equal(
    pad_slide(3:6, .size = 6, .align = "cl")[3:6],
    3:6
  )
  expect_equal(
    pad_slide(4:7, .size = 6, .align = "cr")[1:4],
    c(rep(NA_real_, 3), 4)
  )
  expect_equal(
    pad_slide(4:7, .size = 6, .align = "cr")[4:7],
    4:7
  )
})

test_that("partial sliding with `.step`", {
  xx <- 1:20
  expect_length(
    slide_dbl(xx, mean, na.rm = TRUE, .size = 3, .step = 1, .align = "right", .partial = TRUE),
    length(xx)
  )
  expect_equal(
    slide_dbl(xx, mean, .size = 3, .step = 2, .align = "center", .partial = TRUE)[1:3],
    c(NA, NA, 3)
  )
  expect_length(
    slide_dbl(xx, mean, .size = 3, .step = 2, .align = "center", .partial = TRUE),
    length(xx)
  )
  expect_equal(
    slide_dbl(xx, mean, na.rm = TRUE, .size = 4, .step = 5, .align = "cl", .partial = TRUE)[1:6],
    c(2, NA, NA, NA, NA, 6.5)
  )
  expect_length(
    slide_dbl(xx, mean, na.rm = TRUE, .size = 4, .step = 5, .align = "cl", .partial = TRUE),
    length(xx)
  )
})
