LAYOUTSDIR=source/templates
LAYOUTSEXT='*.nj'
MESSAGESPATH=source/locales/_templates/messages.pot

COMMENTLINE=l10n:

COPYRIGHTHOLDER=Kotsu
PACKAGENAME=Kotsu
PACKAGEVERSION=0.1.0
BUGSEMAIL=https://github.com/LotusTM/Kotsu/issues

JOINEXISTING=false

for file in $(find $LAYOUTSDIR -iname $LAYOUTSEXT)
do
  echo -e "<?phpi18n $(cat $file)" > $file
  echo -e "$(cat $file)i18n ?>" > $file
done

find $LAYOUTSDIR -iname $LAYOUTSEXT | xargs xgettext --language=PHP --from-code=utf-8 -c --add-comments=$COMMENTLINE -o $MESSAGESPATH --no-wrap --sort-by-file --omit-header --copyright-holder=$COPYRIGHTHOLDER --package-name=$PACKAGENAME --package-version=$PACKAGEVERSION --msgid-bugs-address=$BUGSEMAIL --keyword=pgettext:1c,2
# # --join-existing

for file in $(find $LAYOUTSDIR -iname $LAYOUTSEXT)
do
  sed -i -- 's/<?phpi18n //g; s/i18n ?>//g; ${/^$/d;}' $file
done