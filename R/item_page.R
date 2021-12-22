HPT_item <- function(audio_first,
                     audio_second,
                     audio_separator,
                     onsets,
                     offsets,
                     trial_wait,
                     item_number,
                     num_items_in_test,
                     pos_in_test = NA,
                     num_items = NA,
                     feedback = NA,
                     key = NA) {
  num_chords <- length(onsets)
  stopifnot(num_chords > 1)
  chord_ids <- as.character(seq_len(num_chords))
  chord_btn_ids <- paste("chord_btn_", chord_ids, sep = "")
  params <- list(
    audio_first = audio_first,
    audio_second = audio_second,
    audio_separator = audio_separator,
    onsets = onsets,
    offsets = offsets,
    chord_ids = chord_ids,
    chord_btn_ids = chord_btn_ids,
    trial_wait = trial_wait
  )
  if (is.na(key)) {
  prompt <- shiny::tags$div(
    if (!is.na(item_number)) shiny::tags$p(shiny::tags$strong(psychTestR::i18n("PROGRESS_TEXT", sub = c(num_question = item_number,
                                                                                          test_length = num_items_in_test)))),
    shiny::tags$div(psychTestR::i18n("ITEM_INSTRUCTION"), style = "text-align:justify;
                      margin-left:25%;margin-right:25%;margin-bottom:1em"),
    shiny::tags$style(".highlight { background-color: #b0e8f7 !important; color: black !important;}"),
    shiny::tags$script(sprintf("var params = %s;", jsonlite::toJSON(params, auto_unbox = TRUE))),
    shiny::p(
      shiny::tags$strong("Click here to play"),
      id = "play-button",
      style = "visibility: hidden",
      onclick = "play_chord_sequences(); hide_play_button();"
    ),
    shiny::includeScript(system.file("js/hpt-trial.js", package = "HPT"))
    # shiny::actionButton(inputId = "playaudio",
    #                     label = "Play audio",
    #                     onclick = "init_trial();document.getElementById('playaudio').style.visibility='hidden'",
    #                     style = "margin: 20px")
  )}
  else {
    prompt <- shiny::tags$div(
    shiny::tags$div(psychTestR::i18n(key, html = T,
                            sub = list(feedback = feedback)), style = "text-align:justify;
                      margin-left:25%;margin-right:25%;margin-bottom:1em"),
    shiny::tags$style(".highlight { background-color: #b0e8f7 !important; color: black !important;}"),
    shiny::tags$script(sprintf("var params = %s;", jsonlite::toJSON(params, auto_unbox = TRUE))),
    shiny::p(
      shiny::tags$strong("Click here to play"),
      id = "play-button",
      style = "visibility: hidden",
      onclick = "play_chord_sequences(); hide_play_button();"
    ),
    shiny::includeScript(system.file("js/hpt-trial.js", package = "HPT"))
    # shiny::actionButton(inputId = "playaudio",
    #                     label = "Play audio",
    #                     onclick = "init_trial();document.getElementById('playaudio').style.visibility='hidden'",
    #                     style = "margin: 20px")
    )}
  psychTestR::NAFC_page(
    label = paste0("q", item_number),
    prompt = prompt,
    choices = chord_btn_ids,
    labels = chord_ids,
    save_answer = FALSE,
    arrange_vertically = FALSE,
    on_complete = NULL
  )
}
