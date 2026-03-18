import Foundation

struct EsmaItem: Identifiable, Hashable {
    let id: Int
    let name: String
    let arabic: String
    let meaning: String
    let targetCount: Int
    
    // Uygulama geneli statik Esmaül Hüsna listesi
    // Not: Performans ve satır tasarrufu için örnek bir liste verilmiştir.
    static let all: [EsmaItem] = [
        EsmaItem(id: 1, name: "Ya Allah", arabic: "اللَّهُ", meaning: "Eşi benzeri olmayan, bütün noksan sıfatlardan münezzeh tek ilah.", targetCount: 66),
        EsmaItem(id: 2, name: "Ya Rahman", arabic: "الرَّحْمَنُ", meaning: "Dünyada bütün mahlukata merhamet eden, şefkat gösteren.", targetCount: 298),
        EsmaItem(id: 3, name: "Ya Rahim", arabic: "الرَّحِيمُ", meaning: "Ahirette, müminlere sonsuz ikram, lütuf ve ihsanda bulunan.", targetCount: 258),
        EsmaItem(id: 4, name: "Ya Melik", arabic: "الْمَلِكُ", meaning: "Mülkün, kainatın sahibi, mülk ve saltanatı devamlı olan.", targetCount: 90),
        EsmaItem(id: 5, name: "Ya Kuddüs", arabic: "الْقُدُّوسُ", meaning: "Her türlü eksiklikten uzak, bütün kemal sıfatları kendinde toplayan.", targetCount: 170),
        EsmaItem(id: 6, name: "Ya Selam", arabic: "السَّلَامُ", meaning: "Kullarını selamete çıkaran, cennette bahtiyar kullarına selam eden.", targetCount: 131),
        EsmaItem(id: 7, name: "Ya Mü'min", arabic: "الْمُؤْمِنُ", meaning: "Kalplere iman nuru veren, yaratıklarına güven ve huzur bağışlayan.", targetCount: 136),
        EsmaItem(id: 8, name: "Ya Müheymin", arabic: "الْمُهَيْمِنُ", meaning: "Bütün yaratıkları gözetip koruyan.", targetCount: 145),
        EsmaItem(id: 9, name: "Ya Aziz", arabic: "الْعَزِيزُ", meaning: "İzzet sahibi, her şeye galip olan.", targetCount: 94),
        EsmaItem(id: 10, name: "Ya Cebbar", arabic: "الْجَبَّارُ", meaning: "Azamet ve kudret sahibi. Dilediğini yapmaya muktedir olan.", targetCount: 206),
        EsmaItem(id: 11, name: "Ya Mütekebbir", arabic: "الْمُتَكَبِّرُ", meaning: "Büyüklükte eşi ve benzeri olmayan.", targetCount: 662),
        EsmaItem(id: 12, name: "Ya Halik", arabic: "الْخَالِقُ", meaning: "Yoktan var eden, yaratan.", targetCount: 731),
        EsmaItem(id: 13, name: "Ya Bari", arabic: "الْبَارِئُ", meaning: "Her şeyi kusursuz ve uyumlu yaratan.", targetCount: 214),
        EsmaItem(id: 14, name: "Ya Musavvir", arabic: "الْمُصَوِّرُ", meaning: "Varlıklara şekil veren ve onları birbirinden farklı özellikte yaratan.", targetCount: 336),
        EsmaItem(id: 15, name: "Ya Gaffar", arabic: "الْغَفَّارُ", meaning: "Günahları örten ve çok mağfiret eden.", targetCount: 1281)
    ]
}
