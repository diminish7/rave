
def display_usage
  puts "Useage: rave [create | start ] [robot_name] [options]"
  puts "'create' generates a Google Wave robot client stub application."
  puts "e.g."
  puts "rave create my_robot image_url=http://my_robot.appspot.com/image.png profile_url=http://my_robot.appspot.com/"
  puts "'start' launches the robot"
  puts "e.g."
  puts "rave start my_robot"
end