# Mounting shared drives via UTM
`mkdir <mnt_dir>`
`sudo mount -t 9p -o trans=virtio share <mnt_dir> -oversion=9p2000.L`
