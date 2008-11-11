package org.tei.vesta;

import java.io.File;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.util.ArrayList;

import org.eclipse.swt.SWT;
import org.eclipse.swt.custom.CLabel;
import org.eclipse.swt.events.SelectionAdapter;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.layout.FillLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Combo;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.CoolItem;
import org.eclipse.swt.widgets.DirectoryDialog;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.FileDialog;
import org.eclipse.swt.widgets.Group;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Menu;
import org.eclipse.swt.widgets.MessageBox;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.TabFolder;
import org.eclipse.swt.widgets.TabItem;
import org.eclipse.swt.widgets.Text;
import org.eclipse.swt.widgets.ToolBar;
import org.tei.utils.XMLUtils;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;

import com.cloudgarden.resource.SWTResourceManager;


/**
* This code was edited or generated using CloudGarden's Jigloo
* SWT/Swing GUI Builder, which is free for non-commercial
* use. If Jigloo is being used commercially (ie, by a corporation,
* company or business for any purpose whatever) then you
* should purchase a license for each developer using Jigloo.
* Please visit www.cloudgarden.com for details.
* Use of Jigloo implies acceptance of these licensing terms.
* A COMMERCIAL LICENSE HAS NOT BEEN PURCHASED FOR
* THIS MACHINE, SO JIGLOO OR THIS CODE CANNOT BE USED
* LEGALLY FOR ANY CORPORATE OR COMMERCIAL PURPOSE.
*/
public class Vesta extends org.eclipse.swt.widgets.Composite {

	private String selectedFileName;
	private String selectedOutputDir;
	
	private boolean useCompiledODD = true;
	
	private Menu menu1;
	private CLabel selectedOutputDirLabel;
	private CLabel selectedInputFileLabel;
	private Button goButton;
	private Button selectOutputDir;
	private Button selectInputFile;
	private ToolBar toolBar1;
	private CoolItem coolItem1;
	private Button cbCreateXSD;
	private Label selectLanguageLabel;
	private Label imageLabel;
	private Label schemaToGenerateLabel;
	private Label labelPatternPrefix;
	private Text textPatternPrefix;
	private Button cbParameterized;
	private Button cbTEIVersion;
	private Button cbDebug;
	private Button cbCompile;
	private Composite composite1;
	private Button cbDocDocX;
	private Button cbDocHTML;
	private Button cbDocTEI;
	private Button cbCreateRNG;
	private Button cbCreateDTD;
	private Composite optionsTabComposite;
	private Group InputOutputGroup;
	private TabItem advOptionsTab;
	private TabItem optionsTab;
	private TabFolder Options;
	private Combo combLanguage;
	private Combo combSchema;
	private String baseDir;

	{
		//Register as a resource user - SWTResourceManager will
		//handle the obtaining and disposing of resources
		SWTResourceManager.registerResourceUser(this);
	}

	public Vesta(Composite parent, int style) {
		
		super(parent, style);
		
		baseDir = Vesta.class.getProtectionDomain().getCodeSource().getLocation().getPath();
		baseDir = baseDir.substring(0, baseDir.lastIndexOf(File.separator));
		File baseDirFile = new File(baseDir + File.separator + "resources");
		if(!baseDirFile.exists())
			baseDir = baseDir.substring(0, baseDir.lastIndexOf(File.separator));
		
		baseDir += File.separator;
		
		try {
			baseDir = URLDecoder.decode(baseDir,"UTF-8");
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		
		initGUI();
	}
	
	/**
	* Initializes the GUI.
	*/
	private void initGUI() {
		try {
			this.setSize(525, 334);
			this.setLayout(null);
			{
				Options = new TabFolder(this, SWT.NONE);
				{
					optionsTab = new TabItem(Options, SWT.NONE);
					optionsTab.setText("Options");
					{
						optionsTabComposite = new Composite(Options, SWT.NONE);
						optionsTab.setControl(optionsTabComposite);
						optionsTabComposite.setLayout(null);
						{
							cbCreateXSD = new Button(optionsTabComposite, SWT.CHECK | SWT.LEFT);
							cbCreateXSD.setText("generate XSD");
							cbCreateXSD.setBounds(182, 36, 114, 30);
							cbCreateXSD.setSelection(true);
							cbCreateXSD.setToolTipText("Generate a W3C Schema");
						}
						{
							combLanguage = new Combo(optionsTabComposite, SWT.DROP_DOWN | SWT.READ_ONLY | SWT.SINGLE );
							combLanguage.setBounds(0, 36, 159, 30);
							combLanguage.setToolTipText("put a label saying \"language for documentation\"");
							combLanguage.add("English");
							combLanguage.add("Español");
							combLanguage.add("Deutsch");
							combLanguage.add("Français");
							combLanguage.add("Italiano");
							combLanguage.add("日本語");
							combLanguage.add("中文");
							combLanguage.select(0);
						}
						{
							cbCreateRNG = new Button(optionsTabComposite, SWT.CHECK | SWT.LEFT);
							cbCreateRNG.setText("generate RNG");
							cbCreateRNG.setBounds(182, 0, 114, 30);
							cbCreateRNG.setSelection(true);
							cbCreateRNG.setToolTipText("Generate a RELAX NG schema in XML and compact format");
						}
						{
							cbCreateDTD = new Button(optionsTabComposite, SWT.CHECK | SWT.LEFT);
							cbCreateDTD.setText("generate DTD");
							cbCreateDTD.setBounds(182, 72, 114, 30);
							cbCreateDTD.setSelection(true);
							cbCreateDTD.setToolTipText("Generate an XML DTD");
						}
						{
							cbDocTEI = new Button(optionsTabComposite, SWT.CHECK | SWT.LEFT);
							cbDocTEI.setText("documentation (TEI)");
							cbDocTEI.setBounds(316, 0, 173, 30);
							cbDocTEI.setToolTipText("Create documentation for your schema, in TEI XML conforming to the TEI Lite schema");
						}
						{
							cbDocHTML = new Button(optionsTabComposite, SWT.CHECK | SWT.LEFT);
							cbDocHTML.setText("documentation (HTML)");
							cbDocHTML.setBounds(316, 36, 173, 30);
							cbDocHTML.setToolTipText("Create HTML documentation for your schema");
						}
						{
							cbDocDocX = new Button(optionsTabComposite, SWT.CHECK | SWT.LEFT);
							cbDocDocX.setText("documentation (docx)");
							cbDocDocX.setBounds(316, 72, 173, 30);
							cbDocDocX.setToolTipText("Create documentation for your schema as Microsoft Word 2007 document");
						}
						{
							selectLanguageLabel = new Label(optionsTabComposite, SWT.NONE);
							selectLanguageLabel.setText("select language:");
							selectLanguageLabel.setBounds(6, 17, 113, 19);
							selectLanguageLabel.setToolTipText("put a label saying \"language for documentation\"");
						}
					}
				}
				{
					advOptionsTab = new TabItem(Options, SWT.NONE);
					advOptionsTab.setText("Advanced Options");
					{
						composite1 = new Composite(Options, SWT.NONE);
						advOptionsTab.setControl(composite1);
						composite1.setBounds(26, 52, 60, 30);
						composite1.setLayout(null);
						{
							cbCompile = new Button(composite1, SWT.CHECK | SWT.LEFT);
							cbCompile.setText("compile");
							cbCompile.setBounds(12, 0, 102, 30);
							cbCompile.setToolTipText("create intermediate representation of the ODD file after it has been merged with the main TEI");
						}
						{
							cbDebug = new Button(composite1, SWT.CHECK | SWT.LEFT);
							cbDebug.setText("debug");
							cbDebug.setBounds(12, 36, 102, 30);
							cbDebug.setToolTipText("produce verbose messages");
						}
						{
							cbTEIVersion = new Button(composite1, SWT.CHECK | SWT.LEFT);
							cbTEIVersion.setText("use version from TEI");
							cbTEIVersion.setBounds(146, 0, 168, 30);
							cbTEIVersion.setSelection(true);
							cbTEIVersion.setToolTipText("use the date and version of the current TEI Guidelines in documentation, rather than the date and version in your ODD");
						}
						{
							cbParameterized = new Button(composite1, SWT.CHECK | SWT.LEFT);
							cbParameterized.setText("parameterized DTD");
							cbParameterized.setBounds(326, 0, 157, 30);
							cbParameterized.setToolTipText("create a DTD suitable for customizing in a document DTD subset");
						}
						{
							textPatternPrefix = new Text(composite1, SWT.NONE);
							textPatternPrefix.setBounds(242, 42, 230, 22);
							textPatternPrefix.setText("tei_");
							textPatternPrefix.setToolTipText("name all RELAX NG patterns with a name prefix to avoid clashes with other vocabularies");
						}
						{
							labelPatternPrefix = new Label(composite1, SWT.LEFT);
							labelPatternPrefix.setText("pattern prefix:");
							labelPatternPrefix.setBounds(146, 45, 90, 17);
							labelPatternPrefix.setToolTipText("name all RELAX NG patterns with a name prefix to avoid clashes with other vocabularies");
						}
					}
				}
				Options.setSelection(0);
				Options.setBounds(12, 145, 501, 144);
			}
			{
				goButton = new Button(this, SWT.PUSH | SWT.CENTER);
				goButton.setText("Go");
				goButton.setBounds(409, 301, 104, 32);
				goButton.addSelectionListener(new SelectionAdapter() {
					public void widgetSelected(SelectionEvent evt) {
						goButtonWidgetSelected(evt);
					}
				} );
			}
			{
				InputOutputGroup = new Group(this, SWT.NONE);
				InputOutputGroup.setLayout(null);
				InputOutputGroup.setText("");
				InputOutputGroup.setBounds(124, 14, 395, 119);
				{
					selectInputFile = new Button(InputOutputGroup, SWT.PUSH | SWT.CENTER);
					selectInputFile.setText("Select Input File");
					selectInputFile.setBounds(9, 7, 143, 32);
					selectInputFile.setToolTipText("Choose a TEI ODD specification");
					selectInputFile.addSelectionListener(new SelectionAdapter() {
						public void widgetSelected(SelectionEvent evt) {
							FileDialog fileDialog = new FileDialog(getShell());
							fileDialog.setFilterExtensions(new String[]{ "*.odd", "*.xml"});
							selectedFileName = fileDialog.open();
							if(null == selectedFileName)
								return;
							selectedInputFileLabel.setText(selectedFileName);
							
							// read input file in DomDocument and search for schemas
							Document doc = null;
							try {
								doc = XMLUtils.readInputFileIntoJAXPDoc(new File(selectedFileName));
								NodeList list = doc.getDocumentElement().getElementsByTagName("schemaSpec");
								
								if(list.getLength() > 0){
									java.util.List<String> idents = new ArrayList<String>();
									for(int i = 0; i < list.getLength(); i++){
										idents.add(((Element)list.item(0)).getAttribute("ident"));
									}
									combSchema.setItems(idents.toArray(new String[]{}));
									combSchema.select(0);
								} else {
									throw new IllegalArgumentException("Could not find a schemaSpec in the input file.");
								}
								// enable potential disabled gui elements
								cbCreateDTD.setEnabled(true);
								cbCreateRNG.setEnabled(true);
								cbCreateXSD.setEnabled(true);
								cbCompile.setEnabled(true);
								cbDebug.setEnabled(true);
								cbDocTEI.setEnabled(true);
								combLanguage.setEnabled(true);
								cbParameterized.setEnabled(true);
								cbTEIVersion.setEnabled(true);
								textPatternPrefix.setEnabled(true);
								
								cbDocHTML.setText("documentation (HTML)");
								cbDocDocX.setText("documentation (docx)");
								
								// lets create a compiled odd
								useCompiledODD = true;
							} catch (IllegalArgumentException e) {
								// if no schemaSpec was found .. deactivate everything but docx and html
								cbCreateDTD.setEnabled(false);
								cbCreateRNG.setEnabled(false);
								cbCreateXSD.setEnabled(false);
								cbCompile.setEnabled(false);
								cbDebug.setEnabled(false);
								cbDocTEI.setEnabled(false);
								combLanguage.setEnabled(false);
								cbParameterized.setEnabled(false);
								cbTEIVersion.setEnabled(false);
								textPatternPrefix.setEnabled(false);
								
								cbDocHTML.setText("transform to HTML");
								cbDocDocX.setText("transform to docx");
								
								// lets not create a compiled odd but only allow for the transformation
								useCompiledODD = false;
								
								// preselect docX and HTML creation
								cbDocHTML.setSelection(true);
								cbDocDocX.setSelection(true);
							} catch (Exception e) {
								selectedFileName = null;
								selectedInputFileLabel.setText("");
								
								MessageBox mb = new MessageBox(Display.getCurrent().getActiveShell());
								mb.setMessage(e.getMessage());
								mb.open();
							}
							

							
						}
					});
				}
				{
					selectOutputDir = new Button(InputOutputGroup, SWT.PUSH | SWT.CENTER);
					selectOutputDir.setText("Select Output Dir ");
					selectOutputDir.setBounds(9, 45, 143, 32);
					selectOutputDir.setToolTipText("Choose a directory in which Vesta can create schemas and documentation");
					selectOutputDir.addSelectionListener(new SelectionAdapter() {
						public void widgetSelected(SelectionEvent evt) {
							DirectoryDialog dirDialog = new DirectoryDialog(getShell());
							selectedOutputDir = dirDialog.open();
							if(null == selectedOutputDir)
								return;
							selectedOutputDirLabel.setText(selectedOutputDir);
						}
					});
				}
				{
					selectedInputFileLabel = new CLabel(InputOutputGroup, SWT.NONE);
					selectedInputFileLabel.setBounds(158, 9, 226, 30);
					selectedInputFileLabel.setBackground(SWTResourceManager.getColor(203, 203, 203));
					selectedInputFileLabel.setToolTipText("Choose a TEI ODD specification");
				}
				{
					selectedOutputDirLabel = new CLabel(InputOutputGroup, SWT.NONE);
					selectedOutputDirLabel.setBounds(158, 45, 226, 30);
					selectedOutputDirLabel.setBackground(SWTResourceManager.getColor(203, 203, 203));
					selectedOutputDirLabel.setToolTipText("Choose a directory in which Vesta can create schemas and documentation");
				}
				{
					schemaToGenerateLabel = new Label(InputOutputGroup, SWT.RIGHT);
					schemaToGenerateLabel.setText("Select Schema:");
					schemaToGenerateLabel.setBounds(10, 87, 140, 20);
					schemaToGenerateLabel.setToolTipText("Choose which schema to process from your ODD file");
				}
				{
					combSchema = new Combo(InputOutputGroup, SWT.DROP_DOWN | SWT.READ_ONLY | SWT.SINGLE );
					combSchema.setBounds(154, 82, 159, 30);
					combSchema.setToolTipText("Choose which schema to process from your ODD file");
				}
			}
			{
			}
			{
				imageLabel = new Label(this, SWT.NONE);
				try{
					Image image = new Image(Display.getDefault(), baseDir + "resources/images/TEI.png");
					if(null != image){
						imageLabel.setImage(image);
					}
					imageLabel.setBounds(14, 14, 100, 89);
				} catch(Exception e){
					System.out.println(e.getMessage());
					e.printStackTrace();
				}
			}
			{
				menu1 = new Menu(getShell(), SWT.BAR);
				getShell().setMenuBar(menu1);
			}
			this.layout();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	/**
	* Auto-generated main method to display this 
	* org.eclipse.swt.widgets.Composite inside a new Shell.
	*/
	public static void main(String[] args) {
		try{
			Display.setAppName("Vesta");
			Display display = Display.getDefault();
			Shell shell = new Shell(display,SWT.DIALOG_TRIM);
			Vesta inst = new Vesta(shell, SWT.NULL);
			Point size = inst.getSize();
			shell.setLayout(new FillLayout());
			shell.layout();
			
			if(size.x == 0 && size.y == 0) {
				inst.pack();
				shell.pack();
			} else {
				Rectangle shellBounds = shell.computeTrim(0, 0, size.x, size.y);
				shell.setSize(shellBounds.width, shellBounds.height);
			}
			shell.open();
			while (!shell.isDisposed()) {
				if (!display.readAndDispatch())
					display.sleep();
			}
		} catch(Exception e){
			e.printStackTrace();
		}
	}
	
	public Button getCbCreateRNG() {
		return cbCreateRNG;
	}
	
	public Button getCbCreateXSD() {
		return cbCreateXSD;
	}
	
	public Button getCbCreateDTD() {
		return cbCreateDTD;
	}
	
	public Combo getCombLanguage() {
		return combLanguage;
	}
	
	public Button getCbDocTEI() {
		return cbDocTEI;
	}
	
	public Button getCbDocHTML() {
		return cbDocHTML;
	}
	
	public Button getCbDocDocX() {
		return cbDocDocX;
	}
	
	public Button getCbCompile() {
		return cbCompile;
	}
	
	public Button getCbDebug() {
		return cbDebug;
	}
	
	public Button getCbTEIVersion() {
		return cbTEIVersion;
	}
	
	public Text getTextPatternPrefix() {
		return textPatternPrefix;
	}
	
	public Button getCbParameterized() {
		return cbParameterized;
	}
	
	private void goButtonWidgetSelected(SelectionEvent evt) {
		// test that input and output parameters are set
		if  ( null == selectedFileName ||
			  null == selectedOutputDir ||
			  selectedFileName.equals("") || 
			  selectedOutputDir.equals("")){
			MessageBox mb = new MessageBox(getShell());
			mb.setMessage("Please select input file and output directory");
			mb.open();
			return;
		}
		
		// start up processor
		final VestaProcessor proc = new VestaProcessor();
		proc.setOddFile(selectedFileName);
		proc.setOutputDir(selectedOutputDir);
		if(useCompiledODD)
			proc.setSchemaName(combSchema.getItem(combSchema.getSelectionIndex()));
		else {
			String name =new File(selectedFileName).getName();
			if(name.indexOf(".") != -1)
				name = name.substring(0, name.indexOf("."));
			proc.setSchemaName(name);
		}
		proc.setUseCompiledODD(useCompiledODD);
		
		proc.setGenerateDTD(getCbCreateDTD().getSelection());
		proc.setGenerateRNG(getCbCreateRNG().getSelection());
		proc.setGenerateXSD(getCbCreateXSD().getSelection());
		
		// set language
		switch( getCombLanguage().getSelectionIndex() ){
		case 0:
			proc.setLanguage("en");
			break;
		case 1:
			proc.setLanguage("es");
			break;
		case 2:
			proc.setLanguage("de");
			break;
		case 3:
			proc.setLanguage("fr");
			break;
		case 4:
			proc.setLanguage("it");
			break;
		case 5:
			proc.setLanguage("ja");
			break;
		case 6:
			proc.setLanguage("zh-tw");
			break;
		}
		
		// documentation
		proc.setDocumentationDocX(getCbDocDocX().getSelection());
		proc.setDocumentationHTML(getCbDocHTML().getSelection());
		proc.setDocumentationTEI(getCbDocTEI().getSelection());

		// advanced options
		proc.setCompile(getCbCompile().getSelection());
		proc.setDebug(getCbDebug().getSelection());
		proc.setUseVersionFromTEI(getCbTEIVersion().getSelection());
		proc.setParameterizedDTD(getCbParameterized().getSelection());
		proc.setPatternPrefix(getTextPatternPrefix().getText());
	
		Thread procThread = new Thread(proc);
		procThread.start();
	}

}
