import requests
#  https://api.github.com/repos/OWNER/REPO/pulls == Url format for api
response = requests.get("https://api.github.com/repos/kubernetes/kubernetes/pulls")
print(response) #returns Object
#print(response.json()) ##Returns the entire files; quite large; Also converts json to dictionary
print(response.status_code) #Returns status code
details = response.json()
print(len(details))
print("====================================================================================================")
print("====================================================================================================")

for element in range(len(details)):
    print(details[element]["user"]["login"])