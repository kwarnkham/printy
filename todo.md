```
adb shell 'am start -a android.intent.action.VIEW \
    -c android.intent.category.BROWSABLE \
    -d "https://printy.book-mm.com"' \
    com.lunarblessings.printy
```

```
scp build/app/outputs/flutter-apk/app-release.apk root@coffee.book-mm.com:/root/

rm -rf /etc/nginx/html/apk/printy.apk && mv /root/app-release.apk /etc/nginx/html/apk/printy.apk

systemctl restart nginx
```
