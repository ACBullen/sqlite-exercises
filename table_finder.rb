class TableFinder
  attr_reader :id

  def save
    if @id
      self.update
    else
      self.create
    end
  end

end
