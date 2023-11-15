function next_chunk(str, chunk_start, maxlen) {
  var currentChunkLength = 0;
  var last_good_separator = 0;
  var last_medium_separator = 0;
  var last_bad_separator = 0;

  for (var i = chunk_start + 1; i < str.length - 1; i++) {
    c = str[i];
    c2 = str[i - 1] + c;
    if (c2 === '. ' || c2 === '.[' || c2 === '.\n' || c2 === '\n\n') {
      last_good_separator = i;
    }
    if (c === "\n") {
      last_medium_separator = i;
    }
    if (c === " ") {
      last_bad_separator = i;
    }
    console.log('c=' + c + ' / c2=' + c2);
    currentChunkLength++;
    if (currentChunkLength > maxlen) {
      console.log("-----");
      console.log("chunk_start= " + chunk_start);
      if (last_good_separator > 0) {
        console.log("good: " + last_good_separator);
        return last_good_separator - chunk_start + 1;
      } else if (last_medium_separator > 0) {
        console.log("medium" + last_medium_separator);
        return last_medium_separator - chunk_start + 1;
      } else if (last_bad_separator > 0) {
        console.log("bad" + last_bad_separator);
        return last_bad_separator - chunk_start + 1;
      } else {
        console.log("none");
        return i;
      }
    }
  }
  var chunk_len = str.length - chunk_start + 1;
  return chunk_len;
}