Few Tips

For the latest version, go to: https://github.com/phanclan/packer-ext

packer validate template.json
packer inspect template.json

1. You can capture the output of the image build to a file using the following command.
```
packer build httpd.json 2>&1 | sudo tee output.txt
```

2. Then you can extract the new AMI id to a file named ami.txt using the following command.
```
tail -2 output.txt | head -2 | awk 'match($0, /ami-.*/) { print substr($0, RSTART, RLENGTH) }' > sudo ami.txt
```


Pointing to a local vagrant box
```
vagrant box add my-box file:///d:/path/to/file.box
```