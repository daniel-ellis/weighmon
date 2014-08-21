module WeightHelper

  def all_weights
    Weight.all
  end

  def user_weights(name)
    Weight.where(user: name)
  end

  def weights_for_between(name, since, til = Date.today)
    since = since.strftime('%Y-%m-%d') if since.class == Time
    til = til.strftime('%Y-%m-%d') if til.class == Time
    Weight.where(user: name, :date.gte => since, :date.lte => til).desc(:date) if name
    Weight.where(:date.gte => since, :date.lte => til).desc(:date)
  end
  
  def new_weight(user)
    Weight.create(
      user: user[:name],
      date: user[:date],
      weight: user[:weight],
      test: user[:test]
    )
  end

  def history_last_week
    data = []
    users.each.each do |u|
      name = u.user
      user = {
        name: name,
        dates: [],
        values: []
      }
      (Date.today - 7 ).upto(Date.today) do |date|
        user[:dates] << date.strftime
        weight = Weight.where(user: name,:date.gte => date - 20.hours, :date.lte => (date - 4.hours)).first
        val = weight ? kg_to_lbs(weight.weight) : nil
        user[:values] << val
      end
      data << user
    end
    data
  end
  
  def kg_to_lbs(kg)
    (kg * 2.2046).round(2)
  end

  def time_ago_in_words(t)
    time = t.to_i
    seconds = Time.now.to_i - time
    minutes = seconds / 60
    hours = minutes / 60
    days = hours / 24
    years = days / 365
    descriptions = ['Today', 'Yesterday', '2 days ago', '3 days ago', '4 days ago', '5 days ago']
    if days < 6 && days >= 0
      return descriptions[days]
    end
    format = '%A %d %B'
    format += '\'%y' if years > 0
    t.strftime(format)
  end
end