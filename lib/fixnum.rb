class Fixnum
  def round_up_to(n)
    i = self
    while i % n != 0
      i += 1
    end
    i
  end

  def every_nth(n)
    (0..self).select { |i| i % n == 0 }
  end
end