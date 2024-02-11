//
//  DetailViewCont.swift
//  _18Veritabani
//
//  Created by Eray İnal on 19.12.2023.
//

import UIKit
import CoreData

class DetailViewCont: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var artistTextLabel: UITextField!
    @IBOutlet weak var yearTextLabel: UITextField!
    
    //17 Şimdi biz resim ayrıntıları sayfasında 'SAVE' butonunun gözükmesini istemiyoruz ve yine kullanıcı resim seçmeden etkin olmasın istiyoruz o yüzden öncelikle bu 'SAVE' butonunu bu sayfada da tanımlamamız lazım ama 'Action' olarak değil 'Outlet' olarak seçmeliyiz:
    @IBOutlet weak var saveButton: UIButton! //tanımladıktan hemen sonra viewDidLoad içerisine gidip yapmanın yollarına bakalım
    
    
    //12 Şimdi, tableView'da üzerine tıklandığında resmin ayrıntılarını gösteren bir sayfa açmasını istiyoruz, isteersek biz bunun için ayrir VC açar ve başka bir sayfa tasarlayabiliriz ama biz remimizin detaylarını DetailViewCont sayfasında göstermek istiyoruz. Tıklanan resim isminin id'sini alırız ve DetailViewCont içerisinde name, artist ve year attribute'larını id aracılığı ile çekebiliriz. Bunun için öncelikle sayfa başında iki tane variable tanımlayalım
    var chosenPainting = ""
    var chosenPaintingId : UUID?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        //Recognizers:
        //2 Şimdi uygulamada bilgileri eklemek için klavye çıkıyor ama açıldıktan sonra bunu kapatmak için:
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer) //2 burada direkt sayfanın tamamına attık çünkü herhangi bir yere tıklaması yeterli
        
        
        //3 Şimdi ise resim seçtirme olayını yapıyoruz
        imageView.isUserInteractionEnabled = true // Kullanıcı görsele tıklayabiliyor mu = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
        
        
        
        //..12
        if(chosenPainting != ""){
            //..17 tıklanamaz yapmanın bir çok yolu var bunlardan ilki:
            saveButton.isEnabled = false // bu kod butonu soluk halde gösterir ve tıklanamaz
            
            //..17 direkt saklayadabiliriz:
            saveButton.isHidden = true // şimdi biz yukarıda önce oluk hale getirip sonra gizlediğimiz için iki satırda çalışırsa son şekil olan 'gözükmez' şekilde olur.
            //18 Bu işlem tamam şimdi de resim ve ayrıntılar girilmeden 'SAVE' butonuna basılamaz hale getirelim. Bunun içim 'else' kısmına gitmemiz gerek
            
            
            //..12 buranın kodunu yazabilmek için öncelikle ViewController sınıfına gidip, sınıfın başında iki tane variable tanımlamalıyız
            
            //14 ayarlamaları yaptıktan sonra şuan bu methodu yazabiliriz
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Resimler")
            //..14 Bu yukarıdaki 3 satırı zaten biliyoruz, ezber
            //..14 Şimdi filtreleme yapalım
            
            let idString = chosenPaintingId?.uuidString // UUID'yi String'e çeviriyor
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!) //..14 burada format biraz değişik. Bu satırın anlamı: id'si 'idString' ile eşit olan argümanı bana bul. Mesela eğer name'den bulmak istesek kodu şu şekilde modifiye etmemiz gerekecek: fetchRequest.predicate = NSPredicate(format: "name = %@", self.chosenPainting!) ama name'den iki tane kaydedebiliriz ve karışıklık çıkabilir o yüzden doğru yol id ile yapmak
            fetchRequest.returnsObjectsAsFaults = false
            //..14 buraya kadar her şey tamam
            
            //15:
            do{
                let results = try context.fetch(fetchRequest) //..15 bu results bize bir dizi veriyor biz de bu sayede tek tek for loop'a falan da sokabiliyoruz
                
                if(results.count>0){
                    for elem in results as! [NSManagedObject] {
                        if let name = elem.value(forKey: "name") as? String {
                            nameTextField.text = name
                        }
                        
                        if let artist = elem.value(forKey: "artist") as? String {
                            artistTextLabel.text = artist
                        }
                        
                        if let year = elem.value(forKey: "year") as? Int {
                            yearTextLabel.text = String(year)
                        }
                        
                        if let imageData = elem.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                    //16 şimdi her şeyi hallettik ama bazı küçük noktalar var: mesela ayrıntılara bakarken 'SAVE' butonunun çıkmaması lazım, yine mesela resim seçilip büyün bilgiler girilene kadar 'SAVE' butonunun aktif olmaması lazım, yine mesela eklenen resimleri tableView'dan yana kaydırarak silemiyor onu yapmak lazım
                    
                }
            }catch{
                
            }
            
        }
        else{
            //..12 else'de hiçbir şey yazmamaıza gerek yok sadece boş olduğunu görelim diye yazdım, siledebilirdik
            
            //..18
            saveButton.isHidden = false
            saveButton.isEnabled = false //..18 Gözükür olsun ama tıklanamasın diye false yapıyoruz.
            //19 Peki ne zaman tıklansın
        }
        
    }
    
    @objc func hideKeyboard(){  //2 'true' yapınca o saydaki değişiklikleri bitiriyor yani keyword falan açıksa kapatacaktır
        view.endEditing(true)
    }
     
    
    //..3 burada gestureRecognizer için bir fonksiton yazıyoruz. Bu fonk foto seçmek için galeriye götürmesi lazım
    @objc func selectImage(){
        let picker = UIImagePickerController()
        picker.delegate = self  //bu satır hata veriyor çünkü sınıfa iki tane sınıf (UIImagePickerControllerDelegate, UINavigationControllerDelegate) import etmem lazım
        picker.sourceType = .photoLibrary // Burada kaynağı seçiyoruz, kamera mı yoksa galeri mi diye
        picker.allowsEditing = true //böylece kullanıcı seçtiği görseli editleyebilecek, zoomlayabilir croplayabilir..
        present(picker, animated: true, completion: nil) //present ile alert'lerde yaptığımız gibi burada da picker'ı gösterecek
        //..3 Şimdi buraya kadar resmi seçtirdik, asıl olay seçilen bu resim ile ne olacak:
        //..3 öncelikle hemen bu methodun altında başka bir method çağıralım: didFinishPickingMediaWithInfo
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage  //..3 Burada genelde originalImage veya editedImage seçilir. Biz yukarıda normalde allowsEditing=true dedik ama sadece öğrenmek için şimdi original fotoyu alıcam kullanıcıdan.
        
        //..19 resmi seçtikten sonra tıklanabilir olsun:
        saveButton.isEnabled = true
        
        self.dismiss(animated: true, completion: nil)   //..3 En sonda da açtığımız foto seçme ekranını kapatmak için bu satırı yazıyoruz
    }
    //..3 Şimdi biz galeriden fotoğrafı direkt seçtirdik sıkıntı yok, ama önceden galeriye girmeden önce izin istiyordu, istersek biz de öncesinden kullanıcıdan izin isteyebiliriz. Bunun için 'Info' sayfasına gidiyoruz ve + butonundan Privacy - Photo Library Usage Description seçiyoruz ve açıklamaya da 'To Access Photos' tarzında bir şey yazabiliriz. Bunu yaptık ama bizim uygulamada bu izin gözükmeyecektir iphone 13 ve öncesinde gözüküyor.
      
    
    
    @IBAction func saveButton(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate //4 AppDeletage sınıfını burada değişkene atamış olduk
        let context = appDelegate.persistentContainer.viewContext
        
        //5 bu alttaki satırı yazmadan önce 'import CoreData' ile import etmemiz lazım
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Resimler", into: context) // burada "Resimler" yazdığımız yerin _18Veritabanı'nda yazdığımız isimle aynı olması lazım
        
        newPainting.setValue(nameTextField.text!, forKey: "name") //Keylerin önceden _18Veritabani'nda belirlediğimiz 'Attribute'larla aynı olması lazım
        newPainting.setValue(artistTextLabel.text!, forKey: "artist")
        //newPainting.setValue(yearTextLabel, forKey: "year") direkt böyle yaparsak kullanıcı yıl dışında saçma sapan bir şey de girebilir o yüzden:
        if let year = Int(yearTextLabel.text!){
            newPainting.setValue(year, forKey: "year")
        }
        newPainting.setValue(UUID(), forKey: "id") // gördüğümüz gibi id'de işler biraz farklı, UUID bizim için kendinden değer üretiyor ve id'liyor
        
        //Resmime gelince işler biraz daha değişiyor çünkü resim direkt resim olarak saklanmıyor onu data'ya çevirip öyle saklıyoruz o yüzden resimi önce data'ya çevirmem lazım
        let data = imageView.image?.jpegData(compressionQuality: 0.5) //burada completionQuality soruyor yani nasıl zipliyim ben bunu diyor , yüzde kaçını alıp küçülteyim diyor. '0.5' seçerek resimin mb boyutunu yarıya düşürüyorum
        newPainting.setValue(data, forKey: "image")
        
        // şuan kullanıcı resim seçmeden de SAVE butonuna tıklayabilir, bunu yapmadık ama yapılabilir, kolay. Seçmese de bizim default olan 'Select Image' yazılı resimimiz var onu kaydeder ama tabiki saçma olur.
        
        
        // Buraya kadar her şey tamam ve en son bunları context kullanarak kaydetmek var
        do{
            try context.save()
            print("Saved") // Hata çıkmazsa saved yazdırır
            
        }catch{
            print("Error")
        }
        
        
        NotificationCenter.default.post(name: NSNotification.Name("yeniDataGeldi"), object: nil)  //10 kayıt olan gözlemciler için mesaj yollama aleti bu. Bu sınıf bize diğer ViewController'lara bir mesaj yollamama olanak sağlıyor
        //..10 buradan yeniDataGeldi ismi yolluyoruz ve diğer tarafta da yeniDataGeldi diye bir mesaj gelirse ne yapacağını yazıcaz. Peki biz ne yapıcaz, yeniDataGeldi mesajı alınca getData methodunu geri çağırıcaz böylece baştan başlatmış gibi olucaz. Anladığımıza göre yapmaya başlayalım. Gidip mesaj gelince ne yapacağını viewDidLoad içerisinde yazmak yetmez bu yüzden viewWillAppear içerisinde mesaj gelince ne yapacağını yazmak lazım
        self.navigationController?.popViewController(animated: true) //..9 Bu bize 'SAVE' butonuna basınca tableView'a dönmemizi sağlayacak
        
    } 
    
    
    
    
    
    
    
    

}
