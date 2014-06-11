function () {
  values = {}
  values[this.event] = [this.target_id];
  emit(this.envelope_bag_id, values);
}
