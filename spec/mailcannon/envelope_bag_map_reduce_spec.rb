require "spec_helper"

describe MailCannon::EnvelopeBagMapReduce do

  describe "#find_gem_root_path" do

    after(:all) do
      Gem::Specification.any_instance.unstub(:gem_dir)
      Gem::Specification.unstub(:find_by_name)
    end

    context "when gem is found" do
      it "returns the path" do
        mocked_gem_path = "/app/vendor/bundle/ruby/2.0.0/bundler/gems/mailcannon-2c266138c2eb"
        Gem::Specification.stub(:find_by_name).and_return(Gem::Specification.new)
        Gem::Specification.any_instance.stub(:gem_dir).and_return(mocked_gem_path)
        expect(MailCannon::EnvelopeBag.find_gem_root_path).to eq(mocked_gem_path)
      end
    end

    context "when gem is not found" do
      it "returns empty string" do
        Gem::Specification.stub(:find_by_name) do
          raise LoadError.new(message: /mailcannon/)
        end
        expect(MailCannon::EnvelopeBag.find_gem_root_path).to eq("")
      end
    end

    context "when dependence is not found" do
      it "raises error" do
        Gem::Specification.stub(:find_by_name) do
          raise LoadError.new(message: /some_other_gem/)
        end
        expect{ MailCannon::EnvelopeBag.find_gem_root_path }.to raise_error
      end
    end

    context "something else goes wrong" do
      it "raises exception" do
        Gem::Specification.stub(:find_by_name).and_raise(Exception.new)
        expect{ MailCannon::EnvelopeBag.find_gem_root_path }.to raise_exception
      end
    end
  end

  describe "#js_map" do

    before(:each) do
      File.stub(:read) { |path| path }
      MailCannon::EnvelopeBag.instance_variable_set(:@js_map, nil)
    end

    after(:each) do
      File.unstub(:read)
      MailCannon::EnvelopeBag.unstub(:find_gem_root_path)
      MailCannon::EnvelopeBag.instance_variable_set(:@js_map, nil)
    end


    context "when gem is found" do
      it "returns full gem file path" do
        MailCannon::EnvelopeBag.stub(:find_gem_root_path).and_return("path/to/gem")
        expect(MailCannon::EnvelopeBag.js_map).to eq("path/to/gem/lib/mailcannon/reduces/envelope_bag_map.js")
      end
    end

    context "when gem is not found" do
      it "returns file path relative to current location" do
        MailCannon::EnvelopeBag.stub(:find_gem_root_path).and_return("")
        expect(MailCannon::EnvelopeBag.js_map).to eq("lib/mailcannon/reduces/envelope_bag_map.js")
      end
    end
  end

  describe "#js_reduce" do

    before(:each) do
      File.stub(:read) { |path| path }
      MailCannon::EnvelopeBag.instance_variable_set(:@js_reduce, nil)
    end

    after(:each) do
      File.unstub(:read)
      MailCannon::EnvelopeBag.unstub(:find_gem_root_path)
      MailCannon::EnvelopeBag.instance_variable_set(:@js_reduce, nil)
    end

    context "when gem is found" do
      it "returns full gem file path" do
        MailCannon::EnvelopeBag.stub(:find_gem_root_path).and_return("path/to/gem")
        expect(MailCannon::EnvelopeBag.js_reduce).to eq("path/to/gem/lib/mailcannon/reduces/envelope_bag_reduce.js")
      end
    end

    context "when gem is not found" do
      it "returns file path relative to current location" do
        MailCannon::EnvelopeBag.stub(:find_gem_root_path).and_return("")
        expect(MailCannon::EnvelopeBag.js_reduce).to eq("lib/mailcannon/reduces/envelope_bag_reduce.js")
      end
    end
  end


  let!(:envelope_bag) { build(:empty_envelope_bag) }
  let(:envelope_a) { build(:envelope, envelope_bag_id: envelope_bag.id) }
  let(:envelope_b) { build(:envelope, envelope_bag_id: envelope_bag.id) }
  let(:envelope_c) { build(:envelope, envelope_bag_id: envelope_bag.id) }

  def insert_sample_events
    test_hash = [
      {envelope_id: envelope_a.id, envelope_bag_id: envelope_bag.id, email: 'foo1@bar.com', timestamp: 1322000092, unique_arg: 'my unique arg', event: 'delivered', target_id: '1'},
      {envelope_id: envelope_a.id, envelope_bag_id: envelope_bag.id, email: 'foo2@bar.com', timestamp: 1322000093, unique_arg: 'my unique arg', event: 'open', target_id: '2'},
      {envelope_id: envelope_a.id, envelope_bag_id: envelope_bag.id, email: 'foo3@bar.com', timestamp: 1322000094, unique_arg: 'my unique arg', event: 'bounce', type: 'bounce', target_id: '3'},
      {envelope_id: envelope_b.id, envelope_bag_id: envelope_bag.id, email: 'foo1@bar.com', timestamp: 1322000092, unique_arg: 'my unique arg', event: 'delivered', target_id: '1'},
      {envelope_id: envelope_b.id, envelope_bag_id: envelope_bag.id, email: 'foo2@bar.com', timestamp: 1322000093, unique_arg: 'my unique arg', event: 'click', target_id: '2'},
      {envelope_id: envelope_c.id, envelope_bag_id: envelope_bag.id, email: 'foo1@bar.com', timestamp: 1322000092, unique_arg: 'my unique arg', event: 'click', target_id: '1'}
    ]
    MailCannon::SendgridEvent.insert_bulk(test_hash)
  end

  before(:each) do
    envelope_a.save
    envelope_b.save
    envelope_c.save
    insert_sample_events
  end

  describe "#change_events_status_for_envelope" do
    it "sets events status (processed) to :lock(false)" do
      MailCannon::EnvelopeBag.change_events_status_for_envelope_bag(envelope_bag.id, nil, :lock)
      expect(envelope_a.reload.sendgrid_events.where(processed: false).count).to eq(3)
      expect(envelope_b.reload.sendgrid_events.where(processed: false).count).to eq(2)
      expect(envelope_c.reload.sendgrid_events.where(processed: false).count).to eq(1)
    end

    it "sets events status (processed) to :processed(true)" do
      MailCannon::EnvelopeBag.change_events_status_for_envelope_bag(envelope_bag.id, nil, :processed)
      expect(envelope_a.reload.sendgrid_events.where(processed: true).count).to eq(3)
      expect(envelope_b.reload.sendgrid_events.where(processed: true).count).to eq(2)
      expect(envelope_c.reload.sendgrid_events.where(processed: true).count).to eq(1)
    end
  end

  describe ".reduce_statistics_for_envelope_bag" do
    let(:expected_hash_a){
      {
        "posted"=>{"count"=>0.0, "targets"=>[]},
        "processed"=>{"count"=>0.0, "targets"=>[]},
        "delivered"=>{"count"=>2.0, "targets"=>["1", "1"]},
        "open"=>{"count"=>1.0, "targets"=>["2"]},
        "click"=>{"count"=>2.0, "targets"=>["2", "1"]},
        "deferred"=>{"count"=>0.0, "targets"=>[]},
        "spam"=>{"count"=>0.0, "targets"=>[]},
        "unsubscribe"=>{"count"=>0.0, "targets"=>[]},
        "drop"=>{"count"=>0.0, "targets"=>[]},
        "bounce"=>{"count"=>1.0, "targets"=>["3"]},
        "hard_bounce"=>{"count"=>1.0, "targets"=>["3"]},
        "soft_bounce"=>{"count"=>0.0, "targets"=>[]},
        "unknown"=>{"count"=>0.0, "targets"=>[]}
      }
    }

    let(:expected_hash_b){
      {
        "posted"=>{"count"=>0.0, "targets"=>[]},
        "processed"=>{"count"=>0.0, "targets"=>[]},
        "delivered"=>{"count"=>4.0, "targets"=>["1", "1","1", "1"]},
        "open"=>{"count"=>2.0, "targets"=>["2", "2"]},
        "click"=>{"count"=>4.0, "targets"=>["2", "1","2", "1"]},
        "deferred"=>{"count"=>0.0, "targets"=>[]},
        "spam"=>{"count"=>0.0, "targets"=>[]},
        "unsubscribe"=>{"count"=>0.0, "targets"=>[]},
        "drop"=>{"count"=>0.0, "targets"=>[]},
        "bounce"=>{"count"=>2.0, "targets"=>["3","3"]},
        "hard_bounce"=>{"count"=>2.0, "targets"=>["3","3"]},
        "soft_bounce"=>{"count"=>0.0, "targets"=>[]},
        "unknown"=>{"count"=>0.0, "targets"=>[]}
      }
    }

    it "measure reduce output availability" do
      envelope_bag.reduce_statistics
      start_time = Time.now
      while MailCannon::EnvelopeBagStatistic.count==0
        sleep 1
      end
      end_time = Time.now
      diff = end_time-start_time
      expect(diff<1.0).to be_true
    end

    it "creates an EnvelopeStatistic entry" do
      expect{ MailCannon::EnvelopeBag.reduce_statistics_for_envelope_bag(envelope_bag.id) }.to change{ MailCannon::EnvelopeBagStatistic.count }.from(0).to(1)
    end

    it "returns statistics hash/json" do
      envelope_bag.reduce_statistics
      expect(envelope_bag.stats).to eq(expected_hash_a)
    end

    it "merges recurring reduces" do
      envelope_bag.reduce_statistics
      expect(envelope_bag.stats).to eq(expected_hash_a)
      insert_sample_events
      envelope_bag.reduce_statistics
      expect(envelope_bag.stats).to eq(expected_hash_b)
    end
  end

end
