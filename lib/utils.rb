require 'ostruct'
def to_recursive_ostruct(hash)
  OpenStruct.new(hash.each_with_object({}) do |(key, val), memo|
        memo[key] = val.is_a?(Hash) ? to_recursive_ostruct(val) : val
          end)
end

def to_cs_date(date)
  if date
    date.strftime("%Y-%m-%dT00:00:00.000Z")
  else
    nil
  end
end

# [:name [:next 1 2 3] [:other 1 2 3]]
def to_filter_query(arr)
  if arr.is_a? Array
    key = arr.shift
    "(#{key} " +
      arr.map {|sub| to_filter_query(sub)}.join(" ") +
    ")"
  else
    arr.to_s
  end
end
