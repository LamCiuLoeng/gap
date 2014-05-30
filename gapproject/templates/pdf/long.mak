
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>r-pac - GAP</title>

<link type="images/x-icon" rel="shortcut icon" href="/favicon.ico" />
<!-- <link type="text/css" rel="stylesheet" href="/css/impromt.css" /> -->
<link type="text/css" rel="stylesheet" href="/css/screen.css" />
<link type="text/css" rel="stylesheet" href="/css/all.css" />
<!-- <link rel="stylesheet" href="/css/thickbox.css" type="text/css" /> -->
<link rel="stylesheet" href="/css/GAP-style.css" type="text/css" />
<link rel="stylesheet" href="/css/pdflayout.css?v=222" type="text/css" />

</head>
<body>


<div id="label-layout">

<!-- LONG C&C Option -->
<div class="long">
<br />


<!-- <h1>LONG C&C Option</h1> -->

% for jj, size in enumerate(sizes):
<div style="page-break-before:always;">

% if jj > 2:

<div style="margin-bottom:4px;"></div>

% else:

<div style="margin-bottom:${jj * 6}px;"></div>

% endif

${account(traceability, size, coo, care, fibers, care_symbols)}

<div style="margin-bottom: 146px;"></div>
</div>
% endfor


<%def name="account(traceability, size, coo, care, fibers, care_symbols)">

<h1>LONG C&C Option</h1>
<div style="margin-bottom:20px;"></div>


<div class="box1">
	<div class="half-box bb2">
	<div class="text1">
		<div class="care-instructions">
			<ul class="square">
				<li>
					■ ${care['en']}
				</li>
				<li>■ <strong>CA</strong>: ${care['ca']}</li>
			</ul>
		</div>

	</div>
	<div class="space1">
		<div class="black-rectangle"></div>
	</div>
	</div>


	<div class="half-box">
	<div class="space1"></div>

	<div class="text2">
		<div class="brand">OLD NAVY</div>

		<div class="sizes">
			% if size:

			% if size['en']:
			${size['en']}
			% endif

			% if size['ca']:
			<br />
			${size['ca']}
			% endif

			% if size['cn']:
			<br />
			${size['cn']}
			% endif

			% endif
		</div>

		<div class="coo">${coo}</div>
		<div class="rn">RN 54023 CA17897</div>

		<div class="fibers">
		% if fibers:
		% for f in fibers[0:1]:
			<div class="term">${f['tname']}</div>
			<ul class="square">
				<li>■ ${f['en']}</li>
				<li>■ <strong>CA</strong>: ${f['ca']}</li>

				% for i, jp in enumerate(f['jp']):
					% if i == 0:
					<li>■ <strong>JP</strong>: ${jp['pname']} <span class="txt-right">${jp['percent']}</span></li>
					% else:
					<li>${jp['pname']} <span class="txt-right">${jp['percent']}</span></li>
					% endif
				% endfor

				% for i, ch in enumerate(f['ch']):
					% if i == 0:
					<li>■ <strong>CN</strong>: ${ch['percent']} <span class="txt-right">${ch['pname']}</span></li>
					% else:
					<li>${ch['percent']} <span class="txt-right">${ch['pname']}</span></li>
					% endif
				% endfor


				<%doc>
				% for i, uae in enumerate(f['uae']):
					% if i == 0:
					<li>${uae['percent']} <span class="txt-right">${uae['pname']} :<strong>UAE</strong> ■</span></li>
					% else:
					<li>${uae['percent']} <span class="txt-right">${uae['pname']}</span></li>
					% endif
				% endfor
				</%doc>

			</ul>
		% endfor
		% endif
		</div>
	</div>
	</div>
</div>

<div class="box1">
	<div class="half-box bb2">
		<div class="text1">
			% if len(fibers) >= 3:
			% for f in fibers[1:3]:
			<div class="fibers">
				<div class="term">${f['tname']}</div>
				<ul class="square">
					<li>■ ${f['en']}</li>
					<li>■ <strong>CA</strong>: ${f['ca']}</li>

					% for i, jp in enumerate(f['jp']):
						% if i == 0:
						<li>■ <strong>JP</strong>: ${jp['pname']} <span class="txt-right">${jp['percent']}</span></li>
						% else:
						<li>${jp['pname']} <span class="txt-right">${jp['percent']}</span></li>
						% endif
					% endfor

					% for i, ch in enumerate(f['ch']):
						% if i == 0:
						<li>■ <strong>CN</strong>: ${ch['percent']} <span class="txt-right">${ch['pname']}</span></li>
						% else:
						<li>${ch['percent']} <span class="txt-right">${ch['pname']}</span></li>
						% endif
					% endfor

					<%doc>
					% for i, uae in enumerate(f['uae']):
						% if i == 0:
						<li>${uae['percent']} <span class="txt-right">${uae['pname']} :<strong>UAE</strong> ■</span></li>
						% else:
						<li>${uae['percent']} <span class="txt-right">${uae['pname']}</span></li>
						% endif
					% endfor
					</%doc>

				</ul>
			</div>
			% endfor
			% endif

		</div>
		<div class="space1"></div>
	</div>


	<div class="half-box">
	<div class="space1"><div class="black-rectangle2"></div></div>

	<div class="text2">

			% if len(fibers) > 3:
			% for f in fibers[3:]:
			<div class="fibers">
				<div class="term">${f['tname']}</div>
				<ul class="square">
					<li>■ ${f['en']}</li>
					<li>■ <strong>CA</strong>: ${f['ca']}</li>

					% for i, jp in enumerate(f['jp']):
						% if i == 0:
						<li>■ <strong>JP</strong>: ${jp['pname']} <span class="txt-right">${jp['percent']}</span></li>
						% else:
						<li>${jp['pname']} <span class="txt-right">${jp['percent']}</span></li>
						% endif
					% endfor

					% for i, ch in enumerate(f['ch']):
						% if i == 0:
						<li>■ <strong>CN</strong>: ${ch['percent']} <span class="txt-right">${ch['pname']}</span></li>
						% else:
						<li>${ch['percent']} <span class="txt-right">${ch['pname']}</span></li>
						% endif
					% endfor

					<%doc>
					% for i, uae in enumerate(f['uae']):
						% if i == 0:
						<li>${uae['percent']} <span class="txt-right">${uae['pname']} :<strong>UAE</strong> ■</span></li>
						% else:
						<li>${uae['percent']} <span class="txt-right">${uae['pname']}</span></li>
						% endif
					% endfor
					</%doc>

				</ul>
			</div>
			% endfor
			% endif


<!-- 		<div class="warnings">EXCLUSIVE OF DECORATION/À L'EXCEPTION DES GARNITURES/飾り部分を除く/不包括装饰部分/روكيدلا ىلع روصقم</div> -->

		<div class="care-symbols">
				<div class="cs-imgs">
					<!-- <div class="cs-jp">Care Symbols (JP)</div> -->
					<div class="cs-jp">
						% for c in care_symbols['jp']:
							<img src="${c}" />
						% endfor
					</div>
					<!-- <div class="cs-cn">Care Symbols (China(ISO))</div> -->
					<div class="cs-cn">
						% for c in care_symbols['ch']:
							<img src="${c}" />
						% endfor
					</div>
				</div>
		</div>


	</div>
	</div>
</div>

<div style="clear:both"><br /></div>

<div class="box2">
	<div class="space2"></div>
	<div class="text3">
		<div class="care-instructions">
			<ul class="square">
				<li>■ <strong>ID</strong>: ${care['id']}</li>

				% if care['jp']:
				<li>■ <strong>JP</strong>: ${care['jp']}</li>
				% endif

				% if care['ch']:
				<li>■ <strong>CN</strong>: ${care['ch']}</li>
				% endif


				<%doc>
				<li>
					<table border="0" cellspacing="0" cellpadding="0">
						<tr>
							<td width="90%" class="text-align-right">${care['uae']}</td>
							<td class="td-right">&nbsp;:<strong>UAE</strong>&nbsp;■</td>
						</tr>
					</table>
				</li>
				</%doc>
			</ul>
		</div>
	</div>
</div>


<div class="box2">
	<div class="text1">
		<div class="importer-id">
			東京都渋谷区 千駄ヶ谷 5-32-10
			<br />
			ギャップジャパン &nbsp;株式会社
		</div>

		<!-- <div class="traceability">
			S/123456-00 STYLEDESCRIPTI COLORDES
			<br />
			V/12345678 SP14 02/12
		</div> -->

		% if traceability:
		<div class="traceability">

			% if any([traceability['style'], traceability['color_code'], traceability['style_desc'], traceability['cc_desc']]):
			% if traceability['color_code']:
			S/${traceability['style']}-${traceability['color_code']} ${traceability['style_desc']} ${traceability['cc_desc']}
			% else:
			S/${traceability['style']} ${traceability['style_desc']} ${traceability['cc_desc']}
			% endif
			% endif

			% if any([traceability['vendor'], traceability['season'], traceability['manufacture']]):
			<br />
			V/${traceability['vendor']} ${traceability['season']} ${traceability['manufacture']}
			% endif

		</div>
		% endif

	</div>
</div>


<div style="clear:both;"></div>
<div style="font-weight: bold; color: red;">
	<p>The artwork is a reference only and may not be accurate for size and special requirements.  Any garments vendors utilizing this layout for unauthorized production may incur charge backs.
	<br/>
	This document is intended only for use as a reference for the individual or entity to which it is being presented and may contain information, which is privileged and confidential. No reproduction or distribution is permitted without the consent of r-pac International Corporation. </p>
	<p>该图样仅供参考，对于尺寸和特殊要求并不准确。任何服装厂商利用该图样擅自生产，后果自负。
	<br/>
	本文档的目的仅作为个人或组织的参考使用，它所包含的信息是保密的。未经r-pac公司同意不得复制或分发。</p>
</div>

</%def>

</div>


</div>



<!-- <div style="clear:both"><br /><br /></div> -->


<div id="footer"><span style="margin-right:40px">Copyright r-pac International Corp.</span></div>
</body>
</html>
