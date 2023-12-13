# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Results" do
  context "with a hunt started" do
    let(:hunt) { create(:hunt) }
    let(:team) { create(:team, hunt:) }
    let(:video_submission) { create(:video_submission, item: hunt.items.first, team:) }
    let(:photo_submission) { create(:photo_submission, item: hunt.items.second, team:) }

    describe "results page" do
      it "displays the results" do
        visit "/scavenger_hunts/#{hunt.code}/results"
        expect(page).not_to have_content("Results are not yet available!")
        expect(page).to have_content(hunt.name.upcase)
        expect(page).to have_content(team.score)
      end

      it "downloads the results" do
        expect(hunt.archive.attached?).to be(false)
        visit "/scavenger_hunts/#{hunt.code}/results"
        expect(page).to have_content("Download")
        expect { click_on("Download") }.not_to raise_error
      end

      context "locked by time" do
        before do
          hunt.update(ends_at: 1.year.from_now, lock_results: true)
        end

        it "does not display the results" do
          visit "/scavenger_hunts/#{hunt.code}/results"
          expect(page).to have_content("Results are not yet available!")
        end
      end

      context "locked with password" do
        before do
          hunt.update(lock_password: "hunter2")
        end

        it "does not display the results" do
          visit "/scavenger_hunts/#{hunt.code}/results"
          expect(page).to have_content("Results are not yet available!")
        end

        it "displays results after entering password" do
          visit "/scavenger_hunts/#{hunt.code}/results"
          expect(page).to have_content("Results are not yet available!")
          fill_in "Password", with: "hunter2"
          click_on "Unlock Results!"
          expect(page).not_to have_content("Results are not yet available!")
          expect(page).to have_content(hunt.name.upcase)
          expect(page).to have_content(team.score)
        end
      end
    end

    describe "single result page" do
      it "displays the video submission" do
        visit "scavenger_hunts/#{hunt.code}/items/#{video_submission.item_id}"
        within("#items") do
          expect(page).to have_selector("video")
        end
      end

      it "displays the photo submission" do
        allow(ActiveStorage::Current).to receive(:url_options).and_return(host: "localhost:3000")
        visit "scavenger_hunts/#{hunt.code}/items/#{photo_submission.item_id}"
        within("#items") do
          expect(page).to have_selector("img")
        end
      end
    end
  end
end
