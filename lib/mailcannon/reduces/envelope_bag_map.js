function () {

  values = {}

  switch(this.event) {
    case 'spamreport':
    case 'spam_report':
    case 'spam':
      this.event = 'spam';
    break;
  }

  values[this.event] = [this.target_id];
  emit(this.envelope_bag_id, values);
}
