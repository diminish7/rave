
def display_usage
  puts "Useage: rave [create | server ] [robot_name] [options]"
  puts "'create' generates a Google Wave robot client stub application."
  puts "e.g."
  puts "rave create my_robot image_url=http://my_robot.appspot.com/image.png profile_url=http://my_robot.appspot.com/"
  puts "'server' launches the robot"
  puts "e.g."
  puts "rave server"
end