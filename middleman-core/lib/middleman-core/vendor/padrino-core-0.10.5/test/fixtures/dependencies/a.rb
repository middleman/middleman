# This file will be safe loaded three times.
# The first one fail because B and C constant are not defined
# The second one file because B requires C constant so will not be loaded
# The third one B and C are defined

# But here we need some of b.rb
A_result = [B, C]

A = "A"
