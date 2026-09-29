require "test_helper"

class ProfessionalProfileTest < ActiveSupport::TestCase
  setup do
    @psychologist = professional_profiles(:psychologist)
    @psychoanalyst = professional_profiles(:psychoanalyst)
  end

  test "psychologist can issue all document kinds" do
    %w[attendance_declaration receipt progress_report psychological_report].each do |kind|
      assert @psychologist.can_issue?(kind), "psychologist should issue #{kind}"
    end
  end

  test "psychoanalyst can issue common documents" do
    %w[attendance_declaration receipt progress_report].each do |kind|
      assert @psychoanalyst.can_issue?(kind), "psychoanalyst should issue #{kind}"
    end
  end

  test "psychoanalyst cannot issue psychological_report" do
    assert_not @psychoanalyst.can_issue?(:psychological_report)
  end
end
