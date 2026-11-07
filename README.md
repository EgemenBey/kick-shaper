# Kick Shaper

Kick davullar için özgün bir şekillendirme eklentisi. Formatlar: **VST3** ve **AU (.component)**, macOS (Apple Silicon + Intel).

## Parametreler

| Kontrol | Ne yapar |
|---|---|
| Attack | Vuruşun (transient) sesini artırır veya azaltır, -100% ... +100% |
| Sustain | Vuruştan sonraki gövde/kuyruğu artırır veya azaltır, -100% ... +100% |
| Drive / Tone / Sat Mix | Yumuşak (tanh) saturasyon; Tone saturasyondan sonra üst frekansları keser, Sat Mix kuru/ıslak oranı belirler |
| Sub Gain / Sub Freq | Düşük shelf ile sub bölgeyi güçlendirir veya kısar (30-120 Hz) |
| Click Gain / Click Freq | Tıkırtı/beater bölgesini peak EQ ile ayarlar (1.5-9 kHz) |
| Output | Çıkış seviyesi |

Bir kontrole çift tıklayınca varsayılan değerine döner. Varsayılan ayarlarda eklenti sesi değiştirmez (Sat Mix %0).

## Gerekenler (bir kez)

1. Xcode Command Line Tools: `xcode-select --install`
2. CMake: `brew install cmake`
3. İnternet (ilk derlemede JUCE otomatik indirilir)

## Derleme ve kurulum

Terminalde bu klasörde:

```bash
chmod +x build.sh
./build.sh install
```

Bu komut eklentiyi derler, imzalar ve şu klasörlere kopyalar:

- `~/Library/Audio/Plug-Ins/VST3/Kick Shaper.vst3`
- `~/Library/Audio/Plug-Ins/Components/Kick Shaper.component`

Elle kopyalamak istersen `./build.sh` (install olmadan) çalıştır; dosyalar `dist/` klasörüne çıkar, sen istediğin yere kopyalarsın.

Sonra:

- **Logic Pro:** Eklenti Yöneticisi'nden "Tümünü yeniden tara" yap. AU'nun geçerli olduğunu doğrulamak için Terminal'de `auval -v aufx Ksh1 Ksha` çalıştırabilirsin.
- **Studio One:** Ayarlar > Konumlar > VST Eklentileri bölümünde "Yeniden Tara" yap.

## Notlar

- VST2 formatı yoktur; Steinberg yeni VST2 üretimine izin vermiyor. Studio One ve Logic zaten VST3 / AU kullanır.
- Eklenti adı `CMakeLists.txt` içindeki `PRODUCT_NAME` satırından değişir. Piyasada "KickShaper" adlı ticari bir ürün var; eklentiyi başkalarına dağıtacaksan farklı bir ad seç.
- JUCE, GPLv3 veya ticari lisansla kullanılır. Kişisel kullanım için bir sorun yok; dağıtımdan önce JUCE lisans koşullarını kontrol et.
- İşleme sırası: Attack/Sustain -> Sub -> Click -> Saturasyon -> Output.
