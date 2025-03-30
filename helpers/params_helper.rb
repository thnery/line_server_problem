# Params Helper
# Validates the index passed via URL
module ParamsHelper
  def validate_index!(index)
    Integer(index) rescue (halt 400, "Invalid line index")
  end
end
