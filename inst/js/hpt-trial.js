window.AudioContext = window.AudioContext || window.webkitAudioContext;

setTimeout(init_trial, 5);

// params

var context;

var audio = {
  audio_first: {loaded: false, src: params.audio_first},
  audio_second: {loaded: false, src: params.audio_second},
  audio_separator: {loaded: false, src: params.audio_separator}
};

async function init_trial() {
  disable_buttons();
  init_audio_context();
  setTimeout(async function() {
    await load_all_audio();
    let can_play = check_can_play();
    if (can_play) {
      play_chord_sequences();
    } else {
      show_play_button();
    }
  }, params.trial_wait * 1000);
}

function check_can_play() {
  return context.state == "running"
}

function get_play_button() {
  return document.getElementById("play-button")
}

function show_play_button() {
  let btn = get_play_button();
  btn.style.visibility = "visible";
}

function hide_play_button() {
  let btn = get_play_button();
  btn.style.visibility = "hidden";
}

function init_audio_context() {
  if ('webkitAudioContext' in window) context = new webkitAudioContext();
  if ('AudioContext' in window) context = new AudioContext();
  if (!context) {
    alert('ERROR: This test does not work on your browser. Please try another browser like Chrome, Firefox or Safari 14.');
      throw Error('ERROR: No AudioContext available. Try Chrome, Safari or Firefox Nightly.');
  }
  if (context.state == "suspended") {
      context.resume();
  }
}

function disable_buttons() {
  $( "[id^=chord_btn]" ).prop('disabled', true);
}

function enable_buttons() {
  $( "[id^=chord_btn]" ).prop('disabled', false);
}

async function load_all_audio(on_complete) {
  var ids = Object.keys(audio);
  await Promise.all(ids.map(load_audio));
}

async function load_audio(id, on_complete) {
  await new Promise(resolve => {
      var request = new XMLHttpRequest();
      request.open('GET', audio[id].src, true);
      request.responseType = 'arraybuffer';
      request.onload = function() {
        context.decodeAudioData(request.response, function(buffer) {
          audio[id].buffer = buffer;
          audio[id].loaded = true;
          resolve();
        });
      };
      request.send();
  });
}

function play_chord_sequences() {
  play_chord_sequence("audio_first", function() {
    play_audio("audio_separator", function() {
      setTimeout(function() {
        play_chord_sequence("audio_second", enable_buttons);
      }, 750);
    });
  });
}

function play_audio(id, on_complete) {
  var source = context.createBufferSource();
  source.connect(context.destination);
  source.buffer = audio[id].buffer;
  source.start ? source.start(0) : source.noteOn(0);
  source.addEventListener("ended", on_complete);
}

function play_chord_sequence(id, on_complete) {
  var onsets = params.onsets;
  var offsets = params.offsets;
  var chord_btn_ids = params.chord_btn_ids;
  var num_chords = offsets.length;

  var source = context.createBufferSource();
  source.connect(context.destination);
  source.buffer = audio[id].buffer;
  source.start ? source.start(0) : source.noteOn(0);

  for (let i = 0; i < num_chords; i++) {
    let chord_btn_id = chord_btn_ids[i];
    let onset = onsets[i];
    let offset = offsets[i];

    setTimeout(function() {
      console.log("Highlighting " + chord_btn_id);
      $( "#" + chord_btn_id ).addClass("highlight");
    }, onset * 1000);

    setTimeout(function() {
      $( "#" + chord_btn_id ).removeClass("highlight");
    }, offset * 1000);

    source.addEventListener("ended", on_complete);
  }
}
