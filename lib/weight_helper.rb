module WeightHelper

  def weights_for_between(name, since, til = Date.today)
    Weight.where(user: name, :date.gte => since, :date.lte => til).desc(:date)
  end
end