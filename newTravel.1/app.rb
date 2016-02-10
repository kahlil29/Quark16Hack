require 'sinatra'
require 'json'
require 'net/http'
require 'open-uri'
require 'base64'
require 'httparty'
require 'openssl'

AIRPORTS = {
	'IXA'=>'Agartala,Singerbhil Airport (IXA)',
	'AGX'=>'Agatti Island,Agatti Island Airport (AGX)',
	'AGR'=>'Agra,Kheria Airport (AGR)',
	'AMD'=>'Ahmedabad,Ahmedabad Airport (AMD)',
	'AJL'=>'Aizawl,Aizawl Airport (AJL)',
	'AKD'=>'Akola,Akola Airport (AKD)',
	'IXD'=>'Allahabad,Bamrauli Airport (IXD)',
	'IXV'=>'Along,Along Airport (IXV)',
	'ATQ'=>'Amritsar,Raja Sansi Airport (ATQ)',
	'IXU'=>'Aurangabad,Chikkalthana Airport (IXU)',
	'IXB'=>'Bagdogra,Bagdogra Airport (IXB)',
	'RGH'=>'Balurghat,Balurghat Airport (RGH)',
	'BLR'=>'Bangalore,Hindustan Airport (BLR)',
	'BEK'=>'Bareli,Bareli Airport (BEK)',
	'IXG'=>'Belgaum,Sambre Airport (IXG)',
	'BEP'=>'Bellary,Bellary Airport (BEP)',
	'BUP'=>'Bhatinda,Bhatinda Airport (BUP)',
	'BHU'=>'Bhavnagar,Bhavnagar Airport (BHU)',
	'BHO'=>'Bhopal,Bhopal Airport (BHO)',
	'BBI'=>'Bhubaneswar,Bhubaneswar Airport (BBI)',
	'BHJ'=>'Bhuj,Rudra Mata Airport (BHJ)',
	'BKB'=>'Bikaner,Bikaner Airport (BKB)',
	'PAB'=>'Bilaspur,Bilaspur Airport (PAB)',
	'BOM'=>'Bombay (Mumbai),Chhatrapati Shivaji Airport (BOM)',
	'CCU'=>'Calcutta (Kolkata),Netaji Subhas Chandra Airport (CCU)',
	'CBD'=>'Car Nicobar,Car Nicobar Airport (CBD)',
	'IXC'=>'Chandigarh,Chandigarh Airport (IXC)',
	'CJB'=>'Coimbatore,Peelamedu Airport (CJB)',
	'COH'=>'Cooch Behar,Cooch Behar Airport (COH)',
	'CDP'=>'Cuddapah,Cuddapah Airport (CDP)',
	'NMB'=>'Daman,Daman Airport (NMB)',
	'DAE'=>'Daparizo,Daparizo Airport (DAE)',
	'DAI'=>'Darjeeling,Darjeeling Airport (DAI)',
	'DED'=>'Dehra Dun,Dehra Dun Airport (DED)',
	'DEL'=>'Delhi,Indira Gandhi International Airport (DEL)',
	'DEP'=>'Deparizo,Deparizo Airport (DEP)',
	'DBD'=>'Dhanbad,Dhanbad Airport (DBD)',
	'DHM'=>'Dharamsala,Gaggal Airport (DHM)',
	'DIB'=>'Dibrugarh,Chabua Airport (DIB)',
	'DMU'=>'Dimapur,Dimapur Airport (DMU)',
	'DIU'=>'Diu,Diu Airport (DIU)',
	'GAY'=>'Gaya,Gaya Airport (GAY)',
	'GOI'=>'Goa,Dabolim Airport (GOI)',
	'GOP'=>'Gorakhpur,Gorakhpur Airport (GOP)',
	'GUX'=>'Guna,Guna Airport (GUX)',
	'GAU'=>'Guwahati,Borjhar Airport (GAU)',
	'GWL'=>'Gwalior,Gwalior Airport (GWL)',
	'HSS'=>'Hissar,Hissar Airport (HSS)',
	'HBX'=>'Hubli,Hubli Airport (HBX)',
	'HYD'=>'Hyderabad,Begumpet Airport (HYD)',
	'IMF'=>'Imphal,Municipal Airport (IMF)',
	'IDR'=>'Indore,Indore Airport (IDR)',
	'JLR'=>'Jabalpur,Jabalpur Airport (JLR)',
	'JGB'=>'Jagdalpur,Jagdalpur Airport (JGB)',
	'JAI'=>'Jaipur,Sanganeer Airport (JAI)',
	'JSA'=>'Jaisalmer,Jaisalmer Airport (JSA)',
	'IXJ'=>'Jammu,Satwari Airport (IXJ)',
	'JGA'=>'Jamnagar,Govardhanpur Airport (JGA)',
	'IXW'=>'Jamshedpur,Sonari Airport (IXW)',
	'PYB'=>'Jeypore,Jeypore Airport (PYB)',
	'JDH'=>'Jodhpur,Jodhpur Airport (JDH)',
	'JRH'=>'Jorhat,Rowriah Airport (JRH)',
	'IXH'=>'Kailashahar,Kailashahar Airport (IXH)',
	'IXQ'=>'Kamalpur,Kamalpur Airport (IXQ)',
	'IXY'=>'Kandla,Kandla Airport (IXY)',
	'KNU'=>'Kanpur,Kanpur Airport (KNU)',
	'IXK'=>'Keshod,Keshod Airport (IXK)',
	'HJR'=>'Khajuraho,Khajuraho Airport (HJR)',
	'IXN'=>'Khowai,Khowai Airport (IXN)',
	'COK'=>'Kochi,Kochi Airport (COK)',
	'KLH'=>'Kolhapur,Kolhapur Airport (KLH)',
	'KTU'=>'Kota,Kota Airport (KTU)',
	'CCJ'=>'Kozhikode,Calicut International Airport (CCJ)',
	'KUU'=>'Kulu,Bhuntar Airport (KUU)',
	'IXL'=>'Leh,Leh Airport (IXL)',
	'IXI'=>'Lilabari,Lilabari Airport (IXI)',
	'LKO'=>'Lucknow,Amausi Airport (LKO)',
	'LUH'=>'Ludhiana,Ludhiana Airport (LUH)',
	'MAA'=>'Madras (Chennai),Chennai Airport (MAA)',
	'IXM'=>'Madurai,Madurai Airport (IXM)',
	'LDA'=>'Malda,Malda Airport (LDA)',
	'IXE'=>'Mangalore,Bajpe Airport (IXE)',
	'MOH'=>'Mohanbari,Mohanbari Airport (MOH)',
	'MZA'=>'Muzaffarnagar,Muzaffarnagar Airport (MZA)',
	'MZU'=>'Muzaffarpur,Muzaffarpur Airport (MZU)',
	'MYQ'=>'Mysore,Mysore Airport (MYQ)',
	'NAG'=>'Nagpur,Sonegaon Airport (NAG)',
	'NDC'=>'Nanded,Nanded Airport (NDC)',
	'ISK'=>'Nasik,Gandhinagar Airport (ISK)',
	'NVY'=>'Neyveli,Neyveli Airport (NVY)',
	'OMN'=>'Osmanabad,Osmanabad Airport (OMN)',
	'PGH'=>'Pantnagar,Pantnagar Airport (PGH)',
	'IXT'=>'Pasighat,Pasighat Airport (IXT)',
	'IXP'=>'Pathankot,Pathankot Airport (IXP)',
	'PAT'=>'Patna,Patna Airport (PAT)',
	'PNY'=>'Pondicherry,Pondicherry Airport (PNY)',
	'PBD'=>'Porbandar,Porbandar Airport (PBD)',
	'IXZ'=>'Port Blair,Port Blair Airport (IXZ)',
	'PNQ'=>'Pune,Lohegaon Airport (PNQ)',
	'PUT'=>'Puttaparthi,Puttaprathe Airport (PUT)',
	'RPR'=>'Raipur,Raipur Airport (RPR)',
	'RJA'=>'Rajahmundry,Rajahmundry Airport (RJA)',
	'RAJ'=>'Rajkot,Civil Airport (RAJ)',
	'RJI'=>'Rajouri,Rajouri Airport (RJI)',
	'RMD'=>'Ramagundam,Ramagundam Airport (RMD)',
	'IXR'=>'Ranchi,Ranchi Airport (IXR)',
	'RTC'=>'Ratnagiri,Ratnagiri Airport (RTC)',
	'REW'=>'Rewa,Rewa Airport (REW)',
	'RRK'=>'Rourkela,Rourkela Airport (RRK)',
	'RUP'=>'Rupsi,Rupsi Airport (RUP)',
	'SXV'=>'Salem,Salem Airport (SXV)',
	'TNI'=>'Satna,Satna Airport (TNI)',
	'SHL'=>'Shillong,Shillong Airport (SHL)',
	'SSE'=>'Sholapur,Sholapur Airport (SSE)',
	'IXS'=>'Silchar,Kumbhirgram Airport (IXS)',
	'SLV'=>'Simla,Simla Airport (SLV)',
	'SXR'=>'Srinagar,Srinagar Airport (SXR)',
	'STV'=>'Surat,Surat Airport (STV)',
	'TEZ'=>'Tezpur,Salonibari Airport (TEZ)',
	'TEI'=>'Tezu,Tezu Airport (TEI)',
	'TJV'=>'Thanjavur,Thanjavur Airport (TJV)',
	'TRV'=>'Thiruvananthapuram,Thiruvananthapuram International Airport (TRV)',
	'TRZ'=>'Tiruchirapally,Civil Airport (TRZ)',
	'TIR'=>'Tirupati,Tirupati Airport (TIR)',
	'TCR'=>'Tuticorin,Tuticorin Airport (TCR)',
	'UDR'=>'Udaipur,Dabok Airport (UDR)',
	'BDQ'=>'Vadodara,Vadodara Airport (BDQ)',
	'VNS'=>'Varanasi,Varanasi Airport (VNS)',
	'VGA'=>'Vijayawada,Vijayawada Airport (VGA)',
	'VTZ'=>'Visakhapatnam,Visakhapatnam Airport (VTZ)',
	'WGC'=>'Warangal,Warangal Airport (WGC)'
}

get '/' do
	
	#url = 'https://api.test.sabre.com/v1/shop/flights/cheapest/fares/DFW'
	#uri = URI(url)
	#headers = { "Authorization" => "Bearer T1RLAQKai92iOFhLByTQggkF9THNaT70FhBpiBb0+kfJhb2od739LbqGAACg4m89Edr1n5Y9sOj/J48aqV1q18xjGOYSBWrwFtW/JZFJbd55+zrUz2W5XEK6dKQOciZPQQrqJCr0UCyzmIp8TErM+iEOsVf8ilRrpUREZY+TVUzjaPIkgrky2SWJAJn6TIqj1/ABUmbHD1o+USWs/O0/iqdTZKRuZtJjeThycsBizpTlOoZ324YmpXDOqJedJlF6eTdQPp8//n03NWCoxg**" }
	#OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
	#user = HTTParty.get(uri , :headers => headers).first
	#puts user
=begin	
	http = Net::HTTP.new(uri.host, uri.port)
	headers = {
    	'Authorization' => "Bearer T1RLAQKai92iOFhLByTQggkF9THNaT70FhBpiBb0+kfJhb2od739LbqGAACg4m89Edr1n5Y9sOj/J48aqV1q18xjGOYSBWrwFtW/JZFJbd55+zrUz2W5XEK6dKQOciZPQQrqJCr0UCyzmIp8TErM+iEOsVf8ilRrpUREZY+TVUzjaPIkgrky2SWJAJn6TIqj1/ABUmbHD1o+USWs/O0/iqdTZKRuZtJjeThycsBizpTlOoZ324YmpXDOqJedJlF6eTdQPp8//n03NWCoxg**"
	}
	path = uri.path.empty? ? "/" : uri.path

	#test to ensure that the request will be valid - first get the head
	code = http.head(path, headers).code#.to_i

	if ((code >= "200" && code < "300")||(code >= 200 && code < 300)) then

    #the data is available...
    	http.get(uri.path, headers) do |chunk|
        	#provided the data is good, print it...
        	print chunk unless chunk =~ />416.+Range/
    	end
	end
=end	
	 #uri = URI.parse(url)
	# #response = Net::HTTP.get(uri)
	#data = JSON.parse(response)
	#puts data

	#url2 = open(url , "Authorization" => "Bearer T1RLAQKai92iOFhLByTQggkF9THNaT70FhBpiBb0+kfJhb2od739LbqGAACg4m89Edr1n5Y9sOj/J48aqV1q18xjGOYSBWrwFtW/JZFJbd55+zrUz2W5XEK6dKQOciZPQQrqJCr0UCyzmIp8TErM+iEOsVf8ilRrpUREZY+TVUzjaPIkgrky2SWJAJn6TIqj1/ABUmbHD1o+USWs/O0/iqdTZKRuZtJjeThycsBizpTlOoZ324YmpXDOqJedJlF6eTdQPp8//n03NWCoxg**")
	#url2.each do |x|

	#end

	#open("https://api.test.sabre.com/", "") do |file|
	#	file << open(url + "Authorization" => "Bearer T1RLAQKai92iOFhLByTQggkF9THNaT70FhBpiBb0+kfJhb2od739LbqGAACg4m89Edr1n5Y9sOj/J48aqV1q18xjGOYSBWrwFtW/JZFJbd55+zrUz2W5XEK6dKQOciZPQQrqJCr0UCyzmIp8TErM+iEOsVf8ilRrpUREZY+TVUzjaPIkgrky2SWJAJn6TIqj1/ABUmbHD1o+USWs/O0/iqdTZKRuZtJjeThycsBizpTlOoZ324YmpXDOqJedJlF6eTdQPp8//n03NWCoxg**").read
	#	puts file
	#end

	#uri.open("https://api.test.sabre.com/v1/lists/top/destinations?origin=NYC&lookbackweeks=8&topdestinations=5", "Authorization" => "Bearer T1RLAQKai92iOFhLByTQggkF9THNaT70FhBpiBb0+kfJhb2od739LbqGAACg4m89Edr1n5Y9sOj/J48aqV1q18xjGOYSBWrwFtW/JZFJbd55+zrUz2W5XEK6dKQOciZPQQrqJCr0UCyzmIp8TErM+iEOsVf8ilRrpUREZY+TVUzjaPIkgrky2SWJAJn6TIqj1/ABUmbHD1o+USWs/O0/iqdTZKRuZtJjeThycsBizpTlOoZ324YmpXDOqJedJlF6eTdQPp8//n03NWCoxg**")
	#str = uri.read
	#enc1   = Base64.encode64('V1:ktnhqq42jb128wew:DEVCENTER:EXT')
	#plain = Base64.decode64(enc3)
	#puts plain


	#read country and codes from the JSON file to listView
	#destinatn = File.read('countries.json')
	@data = Hash.new
	@data = AIRPORTS

	destinatn = File.read('countries.json')
	@dataD = JSON.parse(destinatn)
	
	theme = File.read('themes.json')
	@dataT = JSON.parse(theme)

	erb :index
end