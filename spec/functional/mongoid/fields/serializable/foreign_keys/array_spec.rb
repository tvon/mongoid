require "spec_helper"

describe Mongoid::Fields::Serializable::ForeignKeys::Array do

  before do
    [ Person, Preference ].each(&:delete_all)
  end

  describe "#<<" do

    context "when the base is new" do

      let(:person) do
        Person.new(:ssn => "345-12-2345")
      end

      let(:preference) do
        Preference.new(:name => "testing")
      end

      before do
        person.preference_ids << preference.id
      end

      it "adds the id to the base keys" do
        person.preference_ids.should == [ preference.id ]
      end

      it "does not set the base key on the inverse" do
        preference.person_ids.should == []
      end
    end

    context "when the base is persisted" do

      let(:person) do
        Person.create(:ssn => "345-12-2349")
      end

      context "when the target is new" do

        let(:preference) do
          Preference.new(:name => "testing")
        end

        before do
          person.preference_ids << preference.id
        end

        it "adds the id to the base keys" do
          person.preference_ids.should == [ preference.id ]
        end

        it "does not set the base key on the inverse" do
          preference.person_ids.should == []
        end
      end

      context "when the target is persisted" do

        let(:preference) do
          Preference.create(:name => "testing")
        end

        before do
          person.preference_ids << preference.id
        end

        it "adds the id to the reloaded base keys" do
          person.reload.preference_ids.should == [ preference.id ]
        end

        it "removes the key from the dirty attributes" do
          person.changes["preference_ids"].should be_nil
        end

        it "sets the base key on the reloaded inverse" do
          preference.reload.person_ids.should == [ person.id ]
        end
      end
    end
  end

  describe "#delete" do

    context "when the base is persisted" do

      let(:person) do
        Person.create(:ssn => "345-12-2349")
      end

      context "when the target is persisted" do

        let(:preference) do
          Preference.create(:name => "testing")
        end

        before do
          person.preference_ids << preference.id
          person.preference_ids.delete(preference.id)
        end

        it "removes the target key" do
          person.reload.preference_ids.should == []
        end

        it "removes the key from the dirty attributes" do
          person.changes["preference_ids"].should be_nil
        end

        it "removes the base key on the reloaded inverse" do
          preference.reload.person_ids.should == []
        end
      end
    end
  end
end
