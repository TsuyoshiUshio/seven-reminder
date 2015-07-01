Feature: Entry a vocabulary
    In order to memorise this word
    A user
    Should entry a vocabulary by entry form

  Scenario: Entry a vocabulary via Web Entry Page
      Given I am on the new_vocabulary page
      And I fill in "vocabulary name" with "yahoo"
      And I fill in "vocabulary definition" with "when you are on the mountain, you'll shout this expression"
      And I fill in "vocabulary example" with "Say yahoo!"
      And I fill in "vocabulary url" with "http://www.yahoo.co.jp"
      And I fill in "vocabulary confirmed" with "true"
      When I press "Create Vocabulary"
      Then page should have notice message "Vacabulary was successfully created."


