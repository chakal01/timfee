class Post < ActiveRecord::Base
	def day
    mois = case self.date.strftime("%B")
    when "January"
      "Janvier"
    when "February"
      "Février"
    when "March"
      "Mars"
    when "April"
      "Avril"
    when "May"
      "May"
    when "June"
      "Juin"
    when "July"
      "Juillet"
    when "August"
      "Août"
    when "September"
      "Septembre"
    when "October"
      "Octobre"
    when "November"
      "Novembre"
    when "December"
      "Décembre"
    else
      "Inconnu"
    end
    return self.date.strftime("%d<br>#{mois}<br>%Y")
	end

end
