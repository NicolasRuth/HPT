source("R/HPT.R")
options(shiny.error = browser)
debug_locally <- !grepl("shiny-server", getwd())

#' Standalone HPT
#'
#' This function launches a standalone testing session for the HPT
#' This can be used for data collection, either in the laboratory or online.
#' @param title (Scalar character) Title to display during testing.
#' @param num_items (Scalar integer) Number of items to be adminstered.
#' @param with_feedback (Scalar boolean) Indicates if performance feedback will be given at the end of the test. Defaults to  FALSE
#' @param take_training (Boolean scalar) Defines whether instructions and training are included.
#' Defaults to TRUE.
#' @param admin_password (Scalar character) Password for accessing the admin panel.
#' @param researcher_email (Scalar character)
#' If not \code{NULL}, this researcher's email address is displayed
#' at the bottom of the screen so that online participants can ask for help.
#' @param languages (Character vector)
#' Determines the languages available to participants.
#' Possible languages include English (\code{"en"}),
#' and German (\code{"de"}).
#' The first language is selected by default
#' @param dict The psychTestR dictionary used for internationalisation.
#' @param validate_id (Character scalar or closure) Function for validating IDs or string "auto" for default validation
#' which means ID should consist only of  alphanumeric characters.
#' @param ... Further arguments to be passed to \code{\link{HPT}()}.
#' @export

HPT_standalone  <- function(title = NULL,
                           num_items = 16L,
                           with_feedback = FALSE,
                           take_training = TRUE,
                           with_welcome = TRUE,
                           admin_password = "conifer",
                           researcher_email = "longgoldstudy@gmail.com",
                           languages = c("en", "de"),
                           dict = HPT::HPT_dict,
                           validate_id = "auto",
                           ...) {
  feedback <- NULL
  if(with_feedback) {
    #feedback <- HPT_feedback_with_score()
    feedback <- HPT_feedback_with_graph()
  }
  elts <- c(
    psychTestR::new_timeline(
      psychTestR::get_p_id(prompt = psychTestR::i18n("ENTER_ID"),
                           button_text = psychTestR::i18n("CONTINUE"),
                           validate = validate_id),
      dict = dict
    ),
    HPT(num_items = num_items,
        take_training = take_training,
        with_welcome =  with_welcome,
        feedback = feedback,
        ...),
    #psychTestRCAT::cat.feedback.graph("HPT"),
    psychTestR::elt_save_results_to_disk(complete = TRUE),
    psychTestR::new_timeline(
      psychTestR::final_page(shiny::p(
        psychTestR::i18n("RESULTS_SAVED"),
        psychTestR::i18n("CLOSE_BROWSER"))
      ), dict = dict)
  )
  if(is.null(title)){
    #extract title as named vector from dictionary
    title <-
      HPT::HPT_dict  %>%
      as.data.frame() %>%
      dplyr::filter(key == "TESTNAME") %>%
      dplyr::select(-key) %>%
      as.list() %>%
      unlist()
    names(title) <- tolower(names(title))
  }

  psychTestR::make_test(
    elts,
    opt = psychTestR::test_options(title = title,
                                   admin_password = admin_password,
                                   researcher_email = researcher_email,
                                   demo = FALSE,
                                   languages = tolower(languages)))
}
