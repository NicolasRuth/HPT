#' HPT feedback (with score)
#'
#' Here the participant is given textual feedback at the end of the test.
#' @param dict The psychTestR dictionary used for internationalisation.
#' @export
#' @examples
#' \dontrun{
#' HPT_demo(feedback = HPT_feedback_with_score())}

HPT_feedback_with_score <- function(dict = HPT::HPT_dict) {
  psychTestR::new_timeline(
    c(
      psychTestR::reactive_page(function(state, ...) {
        results <- psychTestR::get_results(state = state,
                                           complete = TRUE,
                                           add_session_info = FALSE)
        #print(results)
        results <- attr(as.list(results)$HPT$ability, "metadata")$results
        #print(results)
        sum_score <- sum(results$score)
        num_question <- nrow(results)
        #printf("Sum scores: %d, total items: %d", sum_score, num_question)
        text_finish <- psychTestR::i18n("COMPLETED",
                                        html = TRUE,
                                        sub = list(num_question = num_question,
                                                   num_correct = sum_score))
        psychTestR::page(
          ui = shiny::div(
            shiny::p(text_finish),
            shiny::p(psychTestR::trigger_button("next", psychTestR::i18n("CONTINUE")))
          )
        )
      }
      )),
    dict = dict
  )

}

HPT_feedback_graph_normal_curve <- function(perc_correct, x_min = 40, x_max = 160, x_mean = 100, x_sd = 15) {
  q <-
    ggplot2::ggplot(data.frame(x = c(x_min, x_max)), ggplot2::aes(x)) +
    ggplot2::stat_function(fun = dnorm, args = list(mean = x_mean, sd = x_sd)) +
    ggplot2::stat_function(fun = dnorm, args=list(mean = x_mean, sd = x_sd),
                           xlim = c(x_min, (x_max - x_min) * perc_correct + x_min),
                           fill = "lightblue4",
                           geom = "area")
  q <- q + ggplot2::theme_bw()
  #q <- q + scale_y_continuous(labels = scales::percent, name="Frequency (%)")
  #q <- q + ggplot2::scale_y_continuous(labels = NULL)
  x_axis_lab <- sprintf(" %s %s", psychTestR::i18n("TESTNAME"), psychTestR::i18n("VALUE"))
  title <- psychTestR::i18n("SCORE_TEMPLATE")
  fake_IQ <- (x_max - x_min) * perc_correct + x_min
  main_title <- sprintf("%s: %.0f", title, round(fake_IQ, digits = 0))

  q <- q + ggplot2::labs(x = x_axis_lab, y = "")
  q <- q + ggplot2::ggtitle(main_title)
  plotly::ggplotly(q, width = 600, height = 450)
}

#' HPT feedback (with graph)
#'
#' Here the participant is given textual and graphical feedback at the end of the test.
#' @param dict The psychTestR dictionary used for internationalisation.
#' @export
#' @examples
#' \dontrun{
#' HPT_demo(feedback = HPT_feedback_with_score())}

HPT_feedback_with_graph <- function(dict = HPT::HPT_dict) {
  psychTestR::new_timeline(
    c(
      psychTestR::reactive_page(function(state, ...) {
        results <- psychTestR::get_results(state = state, complete = TRUE, add_session_info = FALSE)
        results <- attr(as.list(results)$HPT$ability, "metadata")$results
        #print(results)
        #print(nrow(results))

        perc_correct <- (results$ability_WL[nrow(results)] + 2)/4
        sum_score <- sum(results$score)
        num_question <- nrow(results)
        #perc_correct <- sum_score/num_question
        #printf("Sum scores: %d, total items: %d perc_correct: %.2f", sum_score, num_question, perc_correct)
        text_finish <- psychTestR::i18n("COMPLETED",
                                        html = TRUE,
                                        sub = list(num_question = num_question, num_correct = sum_score))
        norm_plot <- HPT_feedback_graph_normal_curve(perc_correct)
        psychTestR::page(
          ui = shiny::div(
            shiny::p(text_finish),
            shiny::p(norm_plot),
            shiny::p(psychTestR::trigger_button("next", psychTestR::i18n("CONTINUE")))
          )
        )
      }
      )),
    dict = dict
  )

}
