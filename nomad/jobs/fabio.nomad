job "fabio" {
  datacenters = ["ohio"]
  priority = 100
  group "fabio" {
    count = 1
    task "fabio" {
      driver = "raw_exec"

      config {
        command = "fabio"
        args    = ["-proxy.strategy=rr"]
      }

      artifact {
        source      = "https://github.com/fabiolb/fabio/releases/download/v1.5.13/fabio-1.5.13-go1.13.4-linux_amd64"
        destination = "local/fabio"
        mode        = "file"
      }

      resources {
        cpu = 300
        memory = 256
        network {
          mbits = 1

          port "http" {
            static = 9999
          }
          port "ui" {
            static = 9998
          }
        }
      }


    }
  }
}