FactoryGirl.define do	
	
	factory :user do
		name "Testi Tauno"
		email "testi@blaa.fi"
		admin "false"
		moderator "false"
    banned "false"
		title "opiskelija"
		persistent_id Faker::Number.unique.number(20)
	end

	factory :user_student, class: User do
		name "Testi opiskelija"
		email "testi_opiskelija@blaa.fi"
		admin "false"
		moderator "false"
    banned "false"
		title "opiskelija"
		persistent_id Faker::Number.unique.number(20)
	end

	factory :user_student_with_history, class: User do
		name "Testi opiskelija"
		email "testi_opiskelija@blaa.fi"
		admin "false"
		moderator "false"
    banned "false"
		title "opiskelija"
		persistent_id Faker::Number.unique.number(20)
		histories {[FactoryGirl.create(:history_student)]}
	end

	factory :user_with_history, class: User do
		name "Testi Testaaja"
		email "testaaja@blaa.fi"
		admin "false"
		moderator "false"
    banned "false"
		title "opiskelija"
		persistent_id Faker::Number.unique.number(20)
		histories {[FactoryGirl.create(:history)]}
	end

	factory :user_admin, class: User do
		name "Testi Admin"
		email "testaaja@blaa.fi"
		admin "true"
		moderator "false"
    banned "false"
		title "admin"
		persistent_id Faker::Number.unique.number(20)
	end

	factory :user_moderator, class: User do
		name "Testi Mode"
		email "testaaja@blaa.fi"
		admin "false"
		moderator "true"
    banned "false"
		title "työntekijä"
		persistent_id Faker::Number.unique.number(20)
	end

  factory :user_banned, class: User do
    name "Bad person"
    email "get@out.fi"
    admin "false"
    moderator "false"
    banned true
    title ""
    persistent_id Faker::Number.unique.number(20)
  end

	factory :comment do
  		time Time.now
  		text "comment text"
		idea {FactoryGirl.create(:idea)}
	   	user {FactoryGirl.create(:user, persistent_id: Faker::Number.unique.number(20))}
		visible true

  	end

	factory :history do
		time Time.now
		basket "New"		
		idea_id 1
	   	user {FactoryGirl.create(:user, persistent_id: Faker::Number.unique.number(20))}
  	end

  	factory :history_new, class: History do
  		time "2016-07-04 00:00:00"
  		basket "New"
	   	user {FactoryGirl.create(:user, persistent_id: Faker::Number.unique.number(20))}
		idea {FactoryGirl.create(:idea)}
  	end

  	factory :history_student, class: History do
  		time "2016-07-04 00:00:00"
  		basket "New"
	   	user {FactoryGirl.create(:user_student, persistent_id: Faker::Number.unique.number(20))}
		idea {FactoryGirl.create(:idea_student)}
  	end

  	factory :history_without_basket, class: History do
  		time "2016-07-04 00:00:00"  		
	   	user {FactoryGirl.create(:user, persistent_id: Faker::Number.unique.number(20))}
		idea {FactoryGirl.create(:idea)}
  	end

	factory :history_approved, class: History do
  		time "2016-07-04 00:00:01"
  		basket "Approved"
	   	user {FactoryGirl.create(:user_moderator, persistent_id: Faker::Number.unique.number(20))}
		idea {FactoryGirl.create(:idea)}
	end

	factory :history_rejected, class: History do
  		time "2016-07-04 00:00:02"
  		basket "Rejected"
	   	user {FactoryGirl.create(:user_moderator, persistent_id: Faker::Number.unique.number(20))}
		idea {FactoryGirl.create(:idea)}
	end

#ideas and tags belongs_and_has_many to be done

	factory :idea do
		topic "idea topic"
		text "idea text"		
		histories {[FactoryGirl.create(:history)]}
		moderate false
	end

	factory :idea_approved, class: Idea do
		topic "idea topic"
		text "idea text"		
		histories {[FactoryGirl.create(:history_approved)]}
		moderate false
	end

	factory :idea_rejected, class: Idea do
		topic "idea topic"
		text "idea text"		
		histories {[FactoryGirl.create(:history_rejected)]}
		moderate false
	end

	factory :idea_moderate_enabled, class: Idea do
		topic "idea topic"
		text "idea text"		
		histories {[FactoryGirl.create(:history_approved)]}
		moderate true
	end

	factory :idea_new, class: Idea do
		topic "idea topic"
		text "idea text"		
		histories {[FactoryGirl.create(:history_new)]}
		moderate false
	end
  
	factory :idea_student, class: Idea do
		topic "idea topic"
		text "idea text"		
		histories {[FactoryGirl.create(:history)]}
		moderate false
	end
  
	factory :tag do
		text "tag text"
	end
  
  factory :like do
    like_type "like"
    user {FactoryGirl.create(:user, persistent_id: Faker::Number.unique.number(20))}
    idea {FactoryGirl.create(:idea)}
  end

	factory :faq, class: Faq do
		language "language"
		text "text"
	end

end
