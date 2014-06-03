function () {

  values = {}

  switch(this.event) {
    case 'spam_report':
    case 'spam':
      this.event = 'spam';
    break;

    case 'drop':
    case 'dropped':
      this.event = 'drop';
    break;

    case 'bounce':
      if(this.type == "bounce")
        values['hard_bounce'] = [this.target_id];
      else
        values['soft_bounce'] = [this.target_id];
    break;
  }

  values[this.event] = [this.target_id];

  emit(this.envelope_bag_id, values);
}
