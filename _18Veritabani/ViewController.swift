//
//  ViewController.swift
//  _18Veritabani
//
//  Created by Eray İnal on 19.12.2023.
//



// id -> Tipi 'UUID(universal unique id)'. Her eklenen resim için id yaparım ve böylece aynı resmi iki defa kaydetmem veya o id ile ilgili sorun olursa ona ulaşır silerim. Aynı isimle birden fazla resim olabilir ama id özeldir
// image -> bunun tiğini 'Binary Data' olarak seçtim çünkü


// Klavyeyi kapatma olayı DetailViewCount sınıfında


import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    
    
    @IBOutlet weak var myTableView: UITableView!
    
    //7 Burada Resim'i belirtmek için sadece isim kullansak yeter diğerlerini kullanmaya gerek yok onları tıklyıp ayrıntılara girince görecek zaten o yüzden veri olarak sadece name çeksek yeter, hem hızlı da olur
    var nameArr = [String]()
    var idArr = [UUID]()
    
    
    //..12
    var selectedPainting = ""
    var selectedPaintingId : UUID!
    //13 Bunları da yazdıktan sonra bu class'ta gidip iki tane method yazmamız lazım
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
    
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked)) //1 Burada navigationController ile navigasyon bara bile ulaşabiliyoruz hatta sağ kenarına ulaşabiliyoruz ve ulaştıkran sonra UIBarButton ile 'add' butonu ekledik
        
        //6 şimdi gelip table view'ımızı yapıp o kaydettiğimiz verileri tableView'a çekebiliriz
        myTableView.delegate = self
        myTableView.dataSource = self
        
        
        
        getData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("yeniDataGeldi"), object: nil) //..10 burada selector olarak getData'yı çağırdık
        
        //11 ama şimdi bir sorun çıkacak -> veriler duplicate(birden fazla) gözükecek çünkü tutuluyorlar. Bunu düzeltmek için getData() fonksiyonunun başında nameArray ve idArray'i boşaltmamız gerekiyor
    }
    
    
    
    

    @objc func addButtonClicked(){
        selectedPainting = "" //..13
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    
    
    //..6 şimdi gelip table view'ımızı yapıp o kaydettiğimiz verileri tableView'a çekebiliriz
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArr[indexPath.row]
        return cell
    }
    
    //8
    @objc func getData(){
        
        idArr.removeAll(keepingCapacity: false)
        nameArr.removeAll(keepingCapacity: false) //..11 bu iki satırda verilerin ViewControlde duplicate olarak bulunmasını engelledik
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate // Çekmek için de bu sınıfa ulaşmam lazım
        let context = appDelegate.persistentContainer.viewContext
        //..8 Şidmi biz sınıfa ulaştık ve şimdi fetchRequest ile getirmemiz gerekiyor
        
        //..8 bu aşağıdaki kodu yazmadan önce import CoreData yapmam lazım
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Resimler")
        fetchRequest.returnsObjectsAsFaults = false  // Cach'den okuma ile ilgili bir ayar, bunu false yapınca verileri daha hızlı okuyor
        
        do{
            let results = try context.fetch(fetchRequest) //..15 bu results bize bir dizi veriyor biz de bu sayede tek tek for loop'a falan da sokabiliyoruz
            
            if(results.count > 0){
                for result in results as! [NSManagedObject]{
                    if let name = result.value(forKey: "name") as? String {
                        self.nameArr.append(name)
                    }
                    if let id = result.value(forKey: "id") as? UUID{
                        self.idArr.append(id)
                    }
                    
                    self.myTableView.reloadData()   //Yeni bir data geldi kardeşim, kendini güncelle
                    
                    // şimdi gidip bu fonksiyonu viewDidLoad'da çağğıralım
                    // Çağırınca uygulama içinde sadece tableView'da gözükecek, henüz üzerine tıklayınca gitmeyecek, onu birazdan yapıcaz
                    //9 Öncelikle 'SAVE' butonuna tıklayınca uygulamada bir tepki olmuyor yani basıp basmadığını bile anlamıyorsun, o yüzden SAVE'a tıklayınca tekrardan TableView'a gitmesi için SaveButton fonksiyonu içerisine(DetailViewCont sınıfında yazmıştık) 'self.navigationController?.popViewController(animated:true)' yazalım
                    
                    //10 Ve bir de resim ve bilgileri kaydete basıp geri gelince tableView'da göstermiyor, uygulamay baştan başlatmamız lazım, bunun önüne geçmek için yine SaveButton fonksiyonu içerisinde NotificationCenter
                    
                }
            }
        }catch{
            print("Error!!!")
        }
        
        
    }
    
    
    //..13:
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Bu method'da bilgileri alıp diğer sayfaya aktarıcaz
        if(segue.identifier == "toDetailsVC"){
            let destinationVC = segue.destination as! DetailViewCont
            destinationVC.chosenPainting = selectedPainting
            destinationVC.chosenPaintingId = selectedPaintingId
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPainting = nameArr[indexPath.row]
        selectedPaintingId = idArr[indexPath.row]
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
        //..13 tabi bir de addButton methodunda da selectedPainting'i ayarlamamız lazım
    }
    
    
    
    //..16 öncesinde silme işlemi nasıl yapılır ona bakalım:
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
      if (editingStyle == .delete) {
          let appDelegate = UIApplication.shared.delegate as! AppDelegate
          let context = appDelegate.persistentContainer.viewContext
          
          let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Resimler")
          
          let idString = idArr[indexPath.row].uuidString
          fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
          
          fetchRequest.returnsObjectsAsFaults = false
          
          do{
              let results = try context.fetch(fetchRequest)
              
              if(results.count>0){
                  
                  for elem in results as! [NSManagedObject]{
                      if let id = elem.value(forKey: "id") as? UUID{
                          if (id == idArr[indexPath.row]){
                              context.delete(elem)
                              nameArr.remove(at: indexPath.row)
                              idArr.remove(at: indexPath.row)
                              self.myTableView.reloadData()
                              
                              do{
                                  try context.save()
                              }catch{
                                  print("Error!!")
                              }
                              
                              break     // Silmek istediğimiz şey silindiğinde bu loop bitecek
                          }
                      }
                      
                  }
                  
              }
          }catch{
              print("Error!")
          }
      }
    }

    
    

}

