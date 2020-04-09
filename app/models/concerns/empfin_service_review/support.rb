module EmpfinServiceReview::Support
  def search_input
    ctx.find('input[placeholder="Search"]')
  end

  def search_for(name)
    input = search_input
    input.set(name)
    input.native.send_keys(:return)
  end

  def open_record(name, ctx:)
    ctx.find("a[aria-label=\"Open record: #{name}\"]").click
  end

  def arrive_at_business_record(name, ctx:)
    name_input = ctx.find('input[aria-label="Name"]')
    name_input.value == name || flunk("Business Application Name did not match after the link was clicked")
  end
end
